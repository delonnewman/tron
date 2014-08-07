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
      enable :sessions
      enable :logging

      Warden::Manager.serialize_into_session { |u| u.id }
      Warden::Manager.serialize_from_session { |io| User[id] }
  
      Warden::Strategies.add(:vista) do
        def valid?
          params[:email] && params[:site] && params[:access] && params[:verify] 
        end
  
        def authenticate!
          p params
          if user = User.authenticate(params)
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
        config.scope_defaults :default, strategies: [:vista], action: 'unauthenticated'
        config.failure_app = self
      end
      use Rack::Protection
    end

    helpers do
      include WardenHelpers
    end

    get '/login' do
      logger.info "#{request.request_method} - #{request.path_info}"
      haml :login
    end

    post '/login' do
      logger.info "#{request.request_method} - #{request.path_info}"
      flash[:success] = warden.message
      redirect session[:return_to]
    end

    post '/unauthenticated' do
      logger.info "#{request.request_method} - #{request.path_info}"
      session[:return_to] = env['warden.options'][:attempted_path]
      flash[:error] = warden.message
      p warden.message
      p flash[:error]
      redirect to '/login'
    end

    get '/logout' do
      logger.info "#{request.request_method} - #{request.path_info}"
      logout
    end
  end
end
