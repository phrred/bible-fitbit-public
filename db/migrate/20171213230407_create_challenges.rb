class CreateChallenges < ActiveRecord::Migration[5.1]
  def change
    create_table :challenges do |t|
      t.references :sender_ministry, :null => true
      t.references :receiver_ministry, :null => true
      t.boolean :sender_gender, :null => true
      t.boolean :receiver_gender, :null => true
      t.references :sender_peer, :null => true
      t.references :receiver_peer, :null => true
      t.boolean :winner
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
