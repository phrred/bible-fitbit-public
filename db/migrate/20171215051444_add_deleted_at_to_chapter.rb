class AddDeletedAtToChapter < ActiveRecord::Migration[5.1]
  def change
    add_column :chapters, :deleted_at, :datetime
    add_index :chapters, :deleted_at
  end
end
