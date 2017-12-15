class AddDeletedAtToChallenge < ActiveRecord::Migration[5.1]
  def change
    add_column :challenges, :deleted_at, :datetime
    add_index :challenges, :deleted_at
  end
end
