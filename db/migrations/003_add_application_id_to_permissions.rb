Sequel.migration do
  change do
    alter_table :permissions do
      # Associates permission with an application
      # if specified the permission can ONLY be used
      # with the specified application, and the :for
      # parameter can be omiited in `User#can?`
      add_foreign_key :application_id, :applications
    end
  end
end
