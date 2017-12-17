class CreateChallengeReadEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :challenge_read_entries do |t|
      t.datetime :read_at, array: true, default: []
      t.references :challenge
      t.references :user
      t.integer :chapters, array: true, default: []

      t.timestamps
    end
  end
end
