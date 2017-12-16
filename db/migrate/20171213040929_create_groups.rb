class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
		t.string :name
		t.integer :group_type
		t.references :ministry_members, :null => true
    t.references :class_members, :null => true

		t.timestamps
    end
    add_index :groups, :id
    add_index :groups, :name, unique: true
  end
end
