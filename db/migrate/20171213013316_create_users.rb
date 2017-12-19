class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.boolean :gender
      t.references :ministry
      t.references :peer_class
      t.references :lifetime_count
      t.integer :annual_counts, array: true, default: []

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
