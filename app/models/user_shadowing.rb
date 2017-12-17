class UserShadowing < ApplicationRecord
	acts_as_paranoid

	belongs_to :user, :class_name => 'User'
	belongs_to :chapter, :class_name => 'Chapter'

	enum shadowing: { unread: 0, personal: 1}
end
