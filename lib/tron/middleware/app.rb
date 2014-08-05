require 'rack'
require 'rack/flash'
require 'rack/protection'
require 'sinatra/base'
require 'warden'

require_relative '../../tron'
require_relative '../session'
require_relative 'helpers'

module Tron
  class Middleware < Sinatra::Base
    configure do
      Warden::Manager.serialize_into_session { |u| u.id }
      Warden::Manager.serialize_from_session { |io| User[id] }
  
      Warden::Strategies.add(:vista) do
        def valid?
          params[:email] && params[:access] && params[:verify] 
        end
  
        def authenticate!
          if user = User.authenticate?(params)
            success!(user, 'Successfully logged in')
          else
            fail!('Could not login')
          end
        end
      end
  
      use Rack::MethodOverride
      use Rack::Session::Cookie, secret: Tron::Session.secret
      use Rack::Flash, accessorize: [ :error, :success ]
      use Warden::Manager do |config|
        config.scope_defaults :default, strategies: [:vista], action: 'login'
        config.failure_app = self
      end
      use Rack::Protection
    end

    helpers do
      include WardenHelpers
    end

    get '/login' do
      haml :login
    end

    post '/login' do
      session[:return_to] = env['warden.options'][:attempted_path]
      flash.error = warden.message
      redirect to '/login'
    end

    get 'logout' do
      logout
    end
  end
end
