Sequel.migration do
  change do
    alter_table :users do
      add_column :crypted_activation_key, String
      add_column :salt, String
    end
  end
end
