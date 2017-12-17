class CreateUserShadowings < ActiveRecord::Migration[5.1]
  def change
    create_table :user_shadowings do |t|
      t.references :user
      t.references :chapter
      t.integer :shadowing, default: 0

      t.timestamps
    end
  end
end
