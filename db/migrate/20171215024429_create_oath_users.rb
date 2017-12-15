class CreateOathUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :oath_users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :oauth_token
      t.datetime :oauth_expires_at

      t.timestamps
    end
  end
end
