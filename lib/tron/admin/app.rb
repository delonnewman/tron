require 'sinatra/base'
require_relative '../middleware/sinatra'

module Tron
  module Admin
    class App < Sinatra::Base
      register Tron::Sinatra
  
      get '/activate' do
        @user = User.activate!(params)

        if @user.activated?
          haml :activation
        else
          haml :activation_error
        end
      end
  
      before do
        authenticate!
      end
  
      get 'users' do
        current_user.can? :list_users, for: :tron
      end
  
      post 'users' do
        current_user.can? :add_users, for: :tron
      end
  
      get 'users/:id' do
        current_user.can? :view_user, for: :tron
      end
  
      put 'users/:id' do
        current_user.can? :update_user, for: :tron
      end
  
      delete 'users/:id' do
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
