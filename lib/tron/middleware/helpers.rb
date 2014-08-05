require 'warden'
require 'forwardable'

module Tron
  module WardenHelpers
    extend Forwardable
    def warden
      env['warden']
    end

    def_delegators :warden, :authenticate?, :logout

    def authenticate!
      warden.authenticate!
    end
  end
end
