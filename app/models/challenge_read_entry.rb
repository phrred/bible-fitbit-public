class ChallengeReadEntry < ApplicationRecord
	acts_as_paranoid
	
	belongs_to :challenge, :class_name => 'Challenge'
	belongs_to :user, :class_name => 'User'
	has_many :read_event, :class_name => 'ReadEvent'
end
