require 'vista/hui_data'
require 'vista/kernel_hash'
require 'monad/maybe'

module Tron
  class User < Sequel::Model
    many_to_many :permissions, join_table: :user_permissions

    def self.authenticate?(params)
      if find(email: params[:email], activated: true)
        res = Vista::HuiData.login(site_code: params[:site], access_code: Vista::KernelHash.encrypt(params[:access]), verify_code: Vista::KernelHash.encrypt(params[:verify]))
        if res.return.match /^\d+$/
          true
        else
          false
        end
      else
        false
      end
    end

    def grant(per, args={})
      app = args[:for] || raise('application is required, specified by :for')
      
      UserPermission.create user: self, permission: eval_sym(per, Permission), application: eval_sym(app, Application)
    end

    def can?(per, args={})
      app = args[:for]

      if app
        u = UserPermission.find user: self, permission: eval_sym(per, Permission), application: eval_sym(app, Application)
        not u.nil?
      else
        ps = Permission.where(name: eval_sym(per, Permission).to_maybe.name.to_s).map(&:users).select { |us| us.include?(self) }
        not ps.empty?
      end
    end

    def to_s
      name
    end

    private

    def eval_sym(obj, klass)
      obj.is_a?(Symbol) ? klass.find(name: obj.to_s) : obj
    end
  end
end
