class AddResidencyToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :residency, index: true, foreign_key: true
  end
end
