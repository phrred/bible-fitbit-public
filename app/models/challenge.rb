class Challenge < ApplicationRecord
	 acts_as_paranoid

	 belongs_to :sender_ministry, :class_name => 'Challenge'
     belongs_to :receiver_ministry, :class_name => 'Challenge'
     belongs_to :sender_peer, :class_name => 'Challenge'
     belongs_to :receiver_class, :class_name => 'Challenge'
end
