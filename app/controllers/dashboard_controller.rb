class DashboardController < ApplicationController
	include ApplicationHelper

	def show
		chapters_read = UserShadowing.where(user_id: session[:user_id]).count()
		@percentage_of_bible = chapters_read.to_f / bible_chapter_count
	end
end
