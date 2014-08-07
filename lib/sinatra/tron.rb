require 'sinatra/base'
require_relative '../tron/middleware/helpers'
require_relative '../tron/middleware/app'

#
# Sinatra / Tron integration
#
#     # basic.rb
#     require 'sinatra'
#     require 'sinatra/tron'
#
#     get '/' do
#       "you're at the front door"
#     end
#
#     get '/admin' do
#       authenticate!
#       "your're inside the house"
#     end
#
#     # modular.rb
#     require 'sinatra/base'
#     require 'sinatra/tron'
#
#     class HelloApp < Sinatra::Base
#       register Sinatra::Tron
#       
#       get '/' do
#         "you're at the front door"
#       end
#
#       get '/admin' do
#         authenticate!
#         "your're inside the house"
#       end
#     end
#
module Sinatra
  module Tron
    def self.registered(app)
      app.use ::Tron::Middleware
      app.helpers ::Tron::WardenHelpers
    end
  end
  register Tron
end
