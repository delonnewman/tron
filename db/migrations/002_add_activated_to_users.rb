Sequel.migration do
  change do
    alter_table :users do
      add_column :activated, FalseClass, default: false, null: false
    end
  end
end
