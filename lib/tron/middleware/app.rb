require 'sinatra/base'
require 'sinatra_warden'

require_relative '../../tron'

module Tron
  class Middleware < Sinatra::Base
    register Sinatra::Warden
  end
end
