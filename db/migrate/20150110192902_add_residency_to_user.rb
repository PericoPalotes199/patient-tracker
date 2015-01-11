class AddResidencyToUser < ActiveRecord::Migration
  def change
    add_column :users, :residency, :string
  end
end
