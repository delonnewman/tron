require 'rack'
require 'rack/flash'
require 'rack/protection'
require 'sinatra/base'
require 'warden'
require 'haml'
require 'timeout'
require 'pony'

require_relative 'helpers'
require_relative '../model'
require_relative '../utils'

module Tron
  class Middleware < Sinatra::Base
    MESSAGES = {
      MISSING_USER:       'Cannot find user, make sure you entered your email correctly'.freeze,
      SUCCESSFUL_LOGIN:   'You\'ve successfully logged in'.freeze,
      UNSUCCESSFUL_LOGIN: 'Could not login: %WHY%'.freeze 
    }.freeze

    configure do
      use Rack::Session::Cookie, secret: Tron::Session.secret
      use Rack::Protection
      use Rack::MethodOverride
      use Rack::Flash, accessorize: [:error, :success]

      Warden::Manager.serialize_into_session { |u| u.id }
      Warden::Manager.serialize_from_session { |id| User[id] }
  
      Warden::Strategies.add(:vista) do
        def valid?
          !!(params['email'] && params['site'] && params['access'] && params['verify'])
        end
  
        def authenticate!
          return fail!(MESSAGES[:MISSING_USER]) unless user = User.find(email: params['email'])

          begin
            Timeout::timeout(15) do
              user.authenticate! Tron.symbolize_keys(params)
              success!(user, MESSAGES[:SUCCESSFUL_LOGIN])
            end
          rescue Vista::HuiData::CallException => e
            fail!("There was an error communicating with the authentication service")
          rescue Timeout::Error => e
            key = user.set_activation_key!
            Pony.mail(:to => user.email,
                      :from => 'Delon Newman <delon.newman@va.gov>',
                      :subject => "Dragnet Authentication",
                      :body => "Please open the following link to log into Dragnet:\n\nhttps://10.170.100.132/emailLogin?email=#{Tron::Helpers.u(user.email)}&key=#{key}")
            fail!('The authentication service failed. Please check your email for a message from "Delon Newman" with an link to authenticate.')
          rescue => e
            fail!(e.message)
          end
        end
      end

      Warden::Strategies.add(:email) do
        def valid?
          !!(params['email'] && params['key'] && params['access'])
        end
  
        def authenticate!
          return fail!(MESSAGES[:MISSING_USER]) unless user = User.find(email: params['email'])

          begin
            user.email_authenticate! Tron.symbolize_keys(params)
            success!(user, MESSAGES[:SUCCESSFUL_LOGIN])
          rescue => e
            fail!(e.message)
          end
        end
      end

      use Warden::Manager do |config|
        config.scope_defaults :default, strategies: [:vista, :email], action: 'unauthenticated'
        config.failure_app = self
      end

      enable :logging
    end

    helpers do
      include WardenHelpers
    end

    def self.get_or_post(url, &block)
      get(url, &block)
      post(url, &block)
    end

    get '/login' do
      haml :login
    end

    get '/emailLogin' do
      @email, @key = params[:email], params[:key]
      haml :emailLogin
    end

    post '/emailLogin' do
      warden.authenticate(:email)
      flash[:success] = warden.message
      if session[:return_to] == '/emailLogin'
        redirect to '/'
      else
        redirect session[:return_to]
      end
    end

    post '/login' do
      authenticate!
      flash[:success] = warden.message
      if session[:return_to] == '/login'
        redirect to '/'
      else
        redirect session[:return_to]
      end
    end

    get_or_post '/unauthenticated' do
      session[:return_to] = env['warden.options'][:attempted_path]
      flash[:error] = warden.message
      redirect to '/login'
    end

    get '/logout' do
      warden.logout
      flash[:message] = "You've been logged out"
      redirect to '/login'
    end
  end
end
