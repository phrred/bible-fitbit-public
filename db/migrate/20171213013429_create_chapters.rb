class CreateChapters < ActiveRecord::Migration[5.1]
  def change
    create_table :chapters do |t|
      t.string :book
      t.integer :ch_num
      t.integer :verse_count, :null => true
      t.text :themes, array: true, default: []

      t.timestamps
    end
    add_index :chapters, :book
  end
end
