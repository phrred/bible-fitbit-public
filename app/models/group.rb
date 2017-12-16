class Group < ApplicationRecord
	enum group_type: [:ministry, :peer_class]
	has_ancestry
	acts_as_paranoid

	def members
			User.where("ministry_id = ? OR peer_class_id = ?", self.id, self.id)
	end

	# class User < ApplicationRecord
	#   has_many :tasks, ->(user) { unscope(:where).where("owner_id = :id OR assignee_id = :id", id: user.id) }
	# end
	# has_many :members, ->(group) { unscope(:where).where("ministry_id = :id OR peer_class_id = :id", id: group.id)}
	# has_many :members, :class_name => 'User', :foreign_key => ['ministry_id', 'peer_class_id']
	# has_many :ministry_members, :class_name => 'User', :foreign_key => 'ministry_id'
	# has_many :class_members, :class_name => 'User', :foreign_key => 'peer_class_id'
end
