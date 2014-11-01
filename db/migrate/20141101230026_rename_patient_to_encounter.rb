class RenamePatientToEncounter < ActiveRecord::Migration
  def up
    rename_table :patients, :encounters
  end

  def down
    rename_table :patients, :encounters
  end
end
