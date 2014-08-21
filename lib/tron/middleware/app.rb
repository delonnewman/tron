require 'rack'
require 'rack/flash'
require 'rack/protection'
require 'sinatra/base'
require 'warden'
require 'haml'

require_relative '../../tron'
require_relative '../session'
require_relative 'helpers'

module Tron
  class Middleware < Sinatra::Base
    MESSAGES = {
      MISSING_USER:     'Cannot find user',
      SUCCESSFUL_LOGIN: 'You\'ve successfully logged in',
      UNSUCCESSFUL_LOGIN: 'Could not login' 
    }.freeze

    configure do
      enable :logging

      use Rack::Session::Cookie, secret: Tron::Session.secret
      use Rack::Protection

      Warden::Manager.serialize_into_session { |u| u.id }
      Warden::Manager.serialize_from_session { |id| User[id] }
  
      Warden::Strategies.add(:vista) do
        def valid?
          !!(params['email'] && params['site'] && params['access'] && params['verify'])
        end
  
        def authenticate!
          return fail!(MESSAGES[:MISSING_USER]) unless user = User.find(email: params['email'])

          if user.authenticate? Tron.symbolize_keys(params)
            success!(user, MESSAGES[:SUCCESSFUL_LOGIN])
          else
            fail!(MESSAGES[:UNSUCCESSFUL_LOGIN])
          end
        end
      end
  
      use Rack::MethodOverride
      use Rack::Flash, accessorize: [ :error, :success ]
      use Warden::Manager do |config|
        config.scope_defaults :default, strategies: [:vista], action: 'unauthenticated'
        config.failure_app = self
      end
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
      redirect session[:return_to]
    end

    get_or_post '/unauthenticated' do
      session[:return_to] = env['warden.options'][:attempted_path]
      flash[:error] = warden.message
      redirect to '/login'
    end

    get '/logout' do
      logout
    end
  end
end
