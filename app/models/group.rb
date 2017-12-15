class Group < ApplicationRecord
	has_ancestry
	has_many :members, :class_name => 'User'
end
