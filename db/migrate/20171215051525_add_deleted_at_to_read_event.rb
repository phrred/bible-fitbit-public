class AddDeletedAtToReadEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :read_events, :deleted_at, :datetime
    add_index :read_events, :deleted_at
  end
end
