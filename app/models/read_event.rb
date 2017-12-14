class ReadEvent < ApplicationRecord
	belongs_to :user, :class_name => 'User'
	belongs_to :chapter, :class_name => 'Chapter'
end
