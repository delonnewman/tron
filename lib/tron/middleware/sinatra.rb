require 'sinatra/base'
require_relative 'helpers'
require_relative 'app'

module Tron
  module Sinatra
    def self.registered(app)
      app.use Tron::Middleware
      app.helpers Tron::WardenHelpers
    end
  end
end
