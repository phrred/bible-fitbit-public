class CreateChallenges < ActiveRecord::Migration[5.1]
  def change
    create_table :challenges do |t|
      t.references :sender_ministry
      t.references :receiver_ministry
      t.boolean :sender_gender
      t.boolean :receiver_gender
      t.references :sender_peer
      t.references :receiver_class
      t.boolean :winner
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
