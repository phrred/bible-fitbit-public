class Group < ApplicationRecord
	enum group_type: [:ministry, :peer_class]
	has_ancestry
	acts_as_paranoid

	has_many :ministry_members, :class_name => 'User', :foreign_key => 'ministry_id'
	has_many :class_members, :class_name => 'User', :foreign_key => 'peer_class_id'
end
