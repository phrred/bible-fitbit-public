class User < ApplicationRecord
	belongs_to :ministry, :class_name => 'Group'
	belongs_to :peer_class, :class_name => 'Group'
	belongs_to :lifetime_count. class_name => 'Count'
	has_many :annual_counts. class_name => 'Count'
end
