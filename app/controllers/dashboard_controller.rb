class DashboardController < ApplicationController
	include ApplicationHelper

	def show
		user_shadowings = UserShadowing.where(user_id: session[:user_id])
		chapters_read = user_shadowings.count()
		@percentage_of_bible = chapters_read.to_f / bible_chapter_count

		last_read_entry = ReadEvent.where(user_id: session[:user_id]).order("updated_at DESC").first
		if last_read_entry != nil
			@last_book_read = last_read_entry.chapter.book
			last_book_shadowings = user_shadowings.where(book: @last_book_read)
			last_book_chapters_read = last_book_shadowings.count()
			
			book_chapter_count = Chapter.where(book: @last_book_read).count()
			@percentage_of_last_book = last_book_chapters_read.to_f / book_chapter_count
		else
			@percentage_of_last_book = "You need to read the bible"
		end
		
	end
end