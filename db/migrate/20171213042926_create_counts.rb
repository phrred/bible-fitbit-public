class CreateCounts < ActiveRecord::Migration[5.1]
  def change
    create_table :counts do |t|
      t.integer :count
      t.integer :year

      t.timestamps
    end
  end
end
