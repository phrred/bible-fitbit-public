class Group < ApplicationRecord
	enum group_type: [:ministry, :peer_class]
	has_ancestry
	acts_as_paranoid
	
	has_many :members, :class_name => 'User', :foreign_key => 'ministry_id'
end
