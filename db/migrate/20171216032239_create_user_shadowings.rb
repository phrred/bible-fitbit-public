class CreateUserShadowings < ActiveRecord::Migration[5.1]
  def change
    create_table :user_shadowings do |t|
      t.references :user
      t.string :book
      t.integer :shadowing, array: true, default: []
      
      t.timestamps
    end
  end
end
