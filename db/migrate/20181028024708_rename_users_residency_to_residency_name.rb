class RenameUsersResidencyToResidencyName < ActiveRecord::Migration
  def change
    rename_column :users, :residency, :residency_name
  end
end
