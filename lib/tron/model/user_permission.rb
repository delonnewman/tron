require 'forwardable'

module Tron
  class UserPermission < Sequel::Model
    set_primary_key [ :user_id, :application_id, :permission_id ]
    many_to_one :user
    many_to_one :application
    many_to_one :permission

    extend Forwardable

    def_delegators :permission, :name, :description

    plugin :validation_helpers
    def validate
      super
      validates_unique [ :user_id, :application_id, :permission_id ]
    end
  end
end
