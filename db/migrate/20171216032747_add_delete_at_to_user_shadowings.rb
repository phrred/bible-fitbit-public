class AddDeleteAtToUserShadowings < ActiveRecord::Migration[5.1]
  def change
    add_column :user_shadowings, :deleted_at, :datetime
    add_index :user_shadowings, :deleted_at
  end
end
