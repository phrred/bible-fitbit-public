class CreateReadEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :read_events do |t|
      t.boolean :personal_shadowing
      t.references :user
      t.references :chapter

      t.timestamps
    end
  end
end
