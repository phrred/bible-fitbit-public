class Challenge < ApplicationRecord
	 acts_as_paranoid

	 belongs_to :sender_ministry, :class_name => 'Group', optional: true
     belongs_to :receiver_ministry, :class_name => 'Group', optional: true
     belongs_to :sender_peer, :class_name => 'Group', optional: true
     belongs_to :receiver_class, :class_name => 'Group', optional: true
end
