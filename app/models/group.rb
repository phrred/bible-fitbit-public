class Group < ApplicationRecord
	belongs_to :parent_group, :class_name => 'Group'
	has_many :children_groups, :class_name => 'Group'
	has_many :members, :class_name => 'Group'
end
