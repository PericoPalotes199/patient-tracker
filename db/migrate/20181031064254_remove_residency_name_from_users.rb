class RemoveResidencyNameFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :residency_name
  end
end
