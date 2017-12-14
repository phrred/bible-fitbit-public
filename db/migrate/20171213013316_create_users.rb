class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :gender
      t.references :ministry
      t.references :peer_class
      t.references :lifetime_count
      t.references :annual_counts
      
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
