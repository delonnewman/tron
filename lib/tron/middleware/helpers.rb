require 'warden'
require 'forwardable'

module Tron
  module WardenHelpers
    extend Forwardable
    def warden
      env['warden']
    end

    def_delegators :warden, :authenticate!, :authenticate?, :logout
    def_delegator  :warden, :user, :current_user
  end
end
