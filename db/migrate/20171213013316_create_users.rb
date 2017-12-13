class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.primary_key :id
      t.string :email
      t.string :name
      t.string :gender

      t.timestamps
    end
    add_index :users, :id
    add_index :users, :email, unique: true
  end
end
