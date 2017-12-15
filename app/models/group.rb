class Group < ApplicationRecord
	has_ancestry
	acts_as_paranoid
	
	has_many :members, :class_name => 'User'
end
