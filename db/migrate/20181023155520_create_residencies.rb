class CreateResidencies < ActiveRecord::Migration
  def change
    create_table :residencies do |t|
      t.string :name
      t.index :name, unique: true
      t.timestamps null: false
    end
  end
end
