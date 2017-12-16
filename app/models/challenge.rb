class Challenge < ApplicationRecord
	 acts_as_paranoid

	 belongs_to :sender_ministry, :class_name => 'Group'
     belongs_to :receiver_ministry, :class_name => 'Group'
     belongs_to :sender_peer, :class_name => 'Group'
     belongs_to :receiver_class, :class_name => 'Group'
end
