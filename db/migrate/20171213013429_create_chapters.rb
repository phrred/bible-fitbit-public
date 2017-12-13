class CreateChapters < ActiveRecord::Migration[5.1]
  def change
    create_table :chapters do |t|
      t.integer :id
      t.string :book
      t.integer :ch_num
      t.integer :verse_count

      t.timestamps
    end
    add_index :chapters, :id
    add_index :chapters, :book
    add_index :chapters, :ch_num, unique: true
  end
end
