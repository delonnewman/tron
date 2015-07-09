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

  module Helpers
    extend self

    def u(*args)
      URI.encode(*args).gsub('+', '%2B')
    end

    def h(*args)
      CGI.escape_html(*args)
    end

    def if_current_user_can(per, args={}, &blk)
      if current_user.can?(per, args || {})
        blk.call
      else
        permission_error_for permission(per, args)
        redirect to '/'
      end
    end

    def permission(per, pred)
      Permission.to(per, pred)
    end

    def permission_error_for(per)
      per.to_maybe do
        flash[:error] = "You don't have permission to #{per.description}"
      end
    end

    def if_current_user_cannot(per, args={}, &blk)
      if current_user.cannot?(per, args || {})
        blk.call
      end
    end

    private

    def eval_sym(obj, klass)
      obj.is_a?(Symbol) ? klass.find(name: obj.to_s) : obj
    end
  end
end
