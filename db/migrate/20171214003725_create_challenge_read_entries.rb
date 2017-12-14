class CreateChallengeReadEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :challenge_read_entries do |t|
      t.references :challenge
      t.references :user
      t.references :chapters

      t.timestamps
    end
  end
end
