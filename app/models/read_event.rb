class ReadEvent < ApplicationRecord
	acts_as_paranoid
	
	belongs_to :user, :class_name => 'User'
	belongs_to :chapter, :class_name => 'Chapter'
end
