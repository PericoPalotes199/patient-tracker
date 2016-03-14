class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.string :label
      t.references :organization, index: true

      t.timestamps
    end
  end
end
