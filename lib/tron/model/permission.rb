module Tron
  class Permission < Sequel::Model
    many_to_one :application
    many_to_many :users, join_table: :user_permissions
  end
end
