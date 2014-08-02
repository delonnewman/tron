Sequel.migration do
  change do
    create_table :users do
      primary_key :id 
      String      :email, null: false
      String      :name,  null: false
    end

    create_table :applications do
      primary_key :id
      String      :name, null: false
      String      :url,  null: false
    end

    create_table :permissions do
      primary_key :id
      String      :name,        null: false
      String      :description, null: false
    end

    create_table :user_permissions do
      foreign_key :user_id,        :users,        null: false
      foreign_key :application_id, :applications, null: false
      foreign_key :permission_id,  :permissions,  null: false
    end
  end
end
