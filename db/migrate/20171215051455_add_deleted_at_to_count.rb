class AddDeletedAtToCount < ActiveRecord::Migration[5.1]
  def change
    add_column :counts, :deleted_at, :datetime
    add_index :counts, :deleted_at
  end
end
