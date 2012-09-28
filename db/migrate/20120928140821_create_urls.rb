class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.integer :id
      t.text :url

      t.timestamps
    end
  end
end
