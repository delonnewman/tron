require 'rack'
require 'rack/flash'
require 'rack/protection'
require 'sinatra/base'
require 'warden'
require 'haml'

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
      use Rack::Flash, accessorize: [ :error, :success ]

      Warden::Manager.serialize_into_session { |u| u.id }
      Warden::Manager.serialize_from_session { |id| User[id] }
  
      Warden::Strategies.add(:vista) do
        def valid?
          !!(params['email'] && params['site'] && params['access'] && params['verify'])
        end
  
        def authenticate!
          return fail!(MESSAGES[:MISSING_USER]) unless user = User.find(email: params['email'])

          begin
            user.authenticate! Tron.symbolize_keys(params)
            success!(user, MESSAGES[:SUCCESSFUL_LOGIN])
          rescue Vista::HuiData::CallException => e
            fail!("There was an error communicating with the authentication service")
          rescue => e
            fail!(e.message)
          end
        end
      end
  
      use Warden::Manager do |config|
        config.scope_defaults :default, strategies: [:vista], action: 'unauthenticated'
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
