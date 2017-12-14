class ChallengeReadEntry < ApplicationRecord
	belongs_to :challenge, :class_name => 'Challenge'
	belongs_to :user, :class_name => 'User'
	has_many :chapters, :class_name => 'Chapter'

end
