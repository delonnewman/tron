require 'uri'
require 'cgi'
require 'sinatra/base'
require 'sinatra/static_assets'
require 'monad/maybe'

require_relative '../../tron'
require_relative '../../tron/middleware/helpers'
require_relative '../../sinatra/tron'

module Tron
  module Admin
    class App < ::Sinatra::Base
      register ::Sinatra::Tron
      register ::Sinatra::StaticAssets

      helpers do
        include Tron::UserHelpers

        def u(*args)
          URI.encode(*args).gsub('+', '%2B')
        end

        def h(*args)
          CGI.escape_html(*args)
        end
      end
  
      get '/activate' do
        if User.activateable? Tron.symbolize_keys(params)
          logger.info "Activateable - params: #{params.inspect}"
          haml :activation, layout: :simple_layout
        else
          logger.info "Not activatable - params: #{params.inspect}"
          haml :activation_error, layout: :simple_layout
        end
      end

      post '/activate' do
        @user = User.activate Tron.symbolize_keys(params)

        if @user.activated?
          haml :activation_success, layout: :simple_layout
        else
          haml :activation_error, layout: :simple_layout
        end
      end

      get '/?' do
        authenticate!
        if current_user.can? :list_users, for: :tron
          puts "Can list users going to '/users'"
          redirect to '/users'
        else
          puts "Cannot list users, going to look at myself: #{current_user}"
          @user = current_user
          haml :user_view
        end
      end

      before '/users*' do
        authenticate!
      end
  
      get '/users' do
        if_current_user_can :list_users, for: :tron do
          puts "Can list users, here we go!"
          @users = User.all
          haml :user_list
        end
      end
  
      post '/users' do
        current_user.can? :add_users, for: :tron
        redirect to '/users'
      end
  
      get '/users/:id' do
        @user = User[params[:id]]
        if current_user.can? :view_user, for: :tron or current_user == @user
          haml :user_view
        else
          permission_error_for permission(:view_user, for: :tron)
          redirect to '/'
        end
      end

      get '/users/:id/activation' do
        if_current_user_can :activate_users, for: :tron do
          @user = User[params[:id]]
          @key  = @user.set_activation_key!
          haml :user_activation
        end
      end
  
      put '/users/:id' do
        current_user.can? :update_user, for: :tron
      end
  
      delete '/users/:id' do
        current_user.can? :delete_user, for: :tron
      end

      # permissions

      get '/users/:id/permissions' do
        current_user.can? :list_user_permissions, for: :tron
      end

      post '/users/:id/permissions' do
        current_user.can? :add_user_permissions, for: :tron
      end

      delete '/users/:id/permissions/:permission_id' do
        current_user.can? :delete_user_permissions, for: :tron
      end
    end
  end
end
