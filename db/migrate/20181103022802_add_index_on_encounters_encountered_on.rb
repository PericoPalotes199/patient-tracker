class AddIndexOnEncountersEncounteredOn < ActiveRecord::Migration
  def change
    add_index :encounters, :encountered_on
  end
end
