class Count < ApplicationRecord
	acts_as_paranoid

	def owner
		User.where("lifetime_count_id = ? OR annual_count_id = ?", self.id, self.id).take
	end
end
