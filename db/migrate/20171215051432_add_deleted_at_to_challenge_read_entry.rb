class AddDeletedAtToChallengeReadEntry < ActiveRecord::Migration[5.1]
  def change
    add_column :challenge_read_entries, :deleted_at, :datetime
    add_index :challenge_read_entries, :deleted_at
  end
end
