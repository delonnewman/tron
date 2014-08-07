Sequel.migration do
  change do
    alter_table :users do
      add_column :crypted_access_code, String
    end
  end
end
