class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
		t.string :name
		t.references :parent_group
		t.references :children_groups
		t.references :members

		t.timestamps
    end
    add_index :groups, :id
    add_index :groups, :name, unique: true
  end
end
