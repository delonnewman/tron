Sequel.migration do
  change do
    alter_table :users do
      add_column :activation_salt, String
    end
  end
end
