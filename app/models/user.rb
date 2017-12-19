class User < ApplicationRecord
	acts_as_paranoid

	belongs_to :ministry, :class_name => 'Group', foreign_key: "ministry_id"
	belongs_to :peer_class, :class_name => 'Group', foreign_key: "peer_class_id"
	belongs_to :lifetime_count, :class_name => 'Count', foreign_key: "lifetime_count_id"

end
