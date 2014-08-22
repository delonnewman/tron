module Tron
  class Permission < Sequel::Model
    many_to_one :application
    many_to_many :users, join_table: :user_permissions

    def self.to(name, pred={})
      app = pred[:for] || raise('Application is required; specified by :for')
      find name: name.to_s, application_id: Application.named(app).to_maybe.id.unwrap(0) 
    end

    def to_s
      name
    end

    def to_sym
      name.to_sym
    end

    def to_i
      id
    end
  end
end
