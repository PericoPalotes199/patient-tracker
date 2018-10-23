class AddIndexOnUserResidency < ActiveRecord::Migration
  def change
    add_index :users, :residency
  end
end
