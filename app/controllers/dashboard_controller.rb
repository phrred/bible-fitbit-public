class DashboardController < ApplicationController
	include ApplicationHelper

	def config_dashboard
		@_ = Challenge.new()
		session_email = session[:email]
		@user = User.where(email: session_email).take
	end
	def show
		config_dashboard()
		@user_shadowings = UserShadowing.where(user_id: @user)
		chapters_read = @user_shadowings.count()
		@percentage_of_bible = chapters_read.to_f / bible_chapter_count

		last_read_entry = ReadEvent.where(user_id: session[:user_id]).order("updated_at DESC").first
		if last_read_entry != nil
			@last_book_read = last_read_entry.chapter.book
			last_book_shadowings = @user_shadowings.where(book: @last_book_read)
			last_book_chapters_read = last_book_shadowings.count()
			
			book_chapter_count = Chapter.where(book: @last_book_read).count()
			@percentage_of_last_book = last_book_chapters_read.to_f / book_chapter_count
		else
			@percentage_of_last_book = "You need to read the bible"
		end
		see_book_percent_read()
		how_many_reps()
		set_up_pace_chart()
		pace_chart_start = Date.today.beginning_of_week - 21
		while !@your_pace.key?(pace_chart_start)
			pace_chart_start += 7
		end
		@pace_chart_range_labels = [
			pace_chart_start,
			pace_chart_start + 7,
			pace_chart_start + 14,
			pace_chart_start + 21]

		@pace_chart_range_values = [
			@your_pace[pace_chart_start],
			@your_pace[pace_chart_start + 7],
			@your_pace[pace_chart_start + 14],
			@your_pace[pace_chart_start + 21]]
	end


	def see_book_percent_read	
		@book_percentages = {}
		bible_books.each do |book|
			chapters_read = @user_shadowings.where(book: book).count()
			@book_percentages[book] = chapters_read.to_f/Chapter.where(book: book).count()
		end
	end

	def how_many_reps
		@x_axis_max = 0
		@user_readings = ReadEvent.where(user: @user).group(:chapter)
		@book_repetitions = {}
		bible_books.each do |book|
			@book_repetitions[book] = []
			Chapter.where(book: book).pluck(:id).each do |id|
				if !@user_reading.nil? and @user_reading.key?id
					if @user_readings[id] > @x_axis_max
						@x_axis_max = user_readings[id]
					end
					@book_repetitions[book] << @user_readings[id]
				else
					@book_repetitions[book] << 0
				end
			end
			@book_repetitions[book].unshift(@book_repetitions[book].min)
		end
		@x_axis_max += 5
	end

	def set_up_pace_chart
		@your_pace = {}
		date = Date.today.beginning_of_week
		while(@your_pace.size < 52)
			@your_pace[date] = 0
			date = date - 7
		end
		read_events_for_user = ReadEvent.where(user: @user)
		read_events_for_user.each do |read_event|
			if @your_pace.key?(read_event.date.beginning_of_week)
				@your_pace[read_event.date.beginning_of_week] += 1
			else
				@your_pace[read_event.date.beginning_of_week] = 1
			end
		end
		@suggested_max = @your_pace.values.max + 5
	end

	def past_pace
		config_dashboard()
		set_up_pace_chart()
		pace_chart_start = params[:week].to_date - 28
		while !@your_pace.key?(pace_chart_start)
			pace_chart_start += 7
		end
		@pace_chart_range_labels = [
			pace_chart_start,
			pace_chart_start + 7,
			pace_chart_start + 14,
			pace_chart_start + 21]

		@pace_chart_range_values = [
			@your_pace[pace_chart_start],
			@your_pace[pace_chart_start + 7],
			@your_pace[pace_chart_start + 14],
			@your_pace[pace_chart_start + 21]]

		respond_to do |format|
			format.js
		end
	end

	def future_pace
		config_dashboard()
		set_up_pace_chart()
		pace_chart_start = params[:week].to_date + 28
		while !@your_pace.key?(pace_chart_start)
			pace_chart_start -= 7
		end
		pace_chart_start -= 21
		@pace_chart_range_labels = [
			pace_chart_start,
			pace_chart_start + 7,
			pace_chart_start + 14,
			pace_chart_start + 21]

		@pace_chart_range_values = [
			@your_pace[pace_chart_start],
			@your_pace[pace_chart_start + 7],
			@your_pace[pace_chart_start + 14],
			@your_pace[pace_chart_start + 21]]

		respond_to do |format|
			format.js
		end
	end
end
