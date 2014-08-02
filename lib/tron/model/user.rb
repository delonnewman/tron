module Tron
  class User < Sequel::Model
    many_to_many :permissions, join_table: :user_permissions

    def add_permission(per, args={})
      app = args[:for] || raise('application is required, specified by :for')
      
      UserPermission.create(
        user: self,
        permission: resolve_symbol(per, Permission),
        application: resolve_symbol(app, Application)
      )
    end

    private

    def resolve_symbol(obj, klass)
      obj.is_a?(Symbol) ? klass.find(name: obj.to_s) : obj
    end
  end
end
