class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.references :user
      t.string :type
      t.json :content

      t.timestamps
    end
  end
end
