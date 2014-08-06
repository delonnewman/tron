require 'vista/hui_data'
require 'vista/kernel_hash'
require 'monad/maybe'

module Tron
  class User < Sequel::Model
    many_to_many :permissions, join_table: :user_permissions

    def self.authenticate?(params)
      site   = params[:site]   || raise(':site is required')
      access = params[:access] || raise(':access is required')
      verify = params[:verify] || raise(':verify is required')
      email  = params[:email]  || raise(':email is required')

      if find(email: params[:email], activated: true)
        res = Vista::HuiData.login site_code: site, access_code: Vista::KernelHash.encrypt(access), verify_code: Vista::KernelHash.encrypt(verify)
        if res.return.match /^\d+$/
          true
        else
          false
        end
      else
        false
      end
    end

    def self.activate!(params)

    end

    alias activated? activated

    def grant(per, args={})
      app = eval_sym(args[:for] || raise('application is required, specified by :for'), Application)
      
      p = Permission.find(name: eval_sym(per, Permission).to_maybe.name.to_s)
      raise "Cannot grant permission #{p} for #{app}, #{p} works only for #{p.application}" unless p.application.nil? or app == p.application

      UserPermission.create user: self, permission: eval_sym(per, Permission), application: app
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

    def cannot?(per, args)
      not can? per, args || {}
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
