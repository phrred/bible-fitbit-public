class Group < ApplicationRecord
	enum group_type: [:ministry, :peer_class, :state, :region]
	has_ancestry
	acts_as_paranoid

	def members
			User.where("ministry_id = ? OR peer_class_id = ?", self.id, self.id)
	end
end
