class CreateChallenges < ActiveRecord::Migration[5.1]
  def change
    create_table :challenges do |t|
      t.references :sender_ministry, :allow_nil => true
      t.references :receiver_ministry, :allow_nil => true
      t.references
      t.text :valid_books, array: true, default: [], :allow_nil => true
      t.boolean :sender_gender, :allow_nil => true
      t.boolean :receiver_gender, :allow_nil => true
      t.references :sender_peer, :allow_nil => true
      t.references :receiver_peer, :allow_nil => true
      t.boolean :winner
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
  end
end
