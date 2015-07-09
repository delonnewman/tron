Sequel.migration do
  change do
    alter_table :users do
      add_column :activation_expires_on, Date
    end
  end
end
