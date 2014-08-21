require 'warden'
require 'forwardable'

module Tron
  module WardenHelpers
    extend Forwardable
    def warden
      env['warden']
    end

    def_delegators :warden, :authenticate!, :authenticated?, :logout
    def_delegator  :warden, :user, :current_user
  end
end
