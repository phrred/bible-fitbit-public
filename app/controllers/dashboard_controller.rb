class DashboardController < ApplicationController
	include ApplicationHelper

	def config_dashboard
		@_ = Challenge.new()
		session_email = session[:email]
		@user = User.where(email: session_email).take
		@all_ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
	end
	def show
		config_dashboard()
		@group1 = Group.take(1)[0].name
		@group2 = @group1
		@title_text = @group1 + " vs. " + @group2
		@y_axis_max = 10

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
 		generate_your_percentile()

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

	def generate_your_percentile()
		count_ids = Count.where(year: 0).order(:count).pluck(:id)
		your_rank = count_ids.index(@user.lifetime_count.id)
		@your_ranking = your_rank*100/count_ids.size()
		@next_percentile = (@your_ranking/10+1).floor*10
		@next_percentile_id = (@next_percentile/100*count_ids.size()).floor
		@next_ten_percent = Count.where(id: count_ids[@next_percentile_id]).pluck(:count)
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
		read_events_for_user = ReadEvent.where(user: @user)
		read_events_for_user.each do |read_event|
			if @your_pace.key?(read_event.date.beginning_of_week)
				@your_pace[read_event.date.beginning_of_week] += 1
			else
				@your_pace[read_event.date.beginning_of_week] = 1
			end
		end
		date = Date.today.beginning_of_week
		while(@your_pace.size < 52)
			@your_pace[date] = 0
			date = date - 7
		end
		while @your_pace.keys.min < date
			@your_pace[date] = 0
			date = date - 7
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

	def comparison_values
		other_params = params[:challenge]
		group1_model = Group.where(name: other_params[:sender_ministry])[0]
		group2_model = Group.where(name: other_params[:receiver_ministry])[0]
		@group1 = group1_model.name
		@group2 = group2_model.name
		count_sums = {}
		@all_ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		@all_users = User.all
		year = Date.today.to_time.strftime('%Y').to_i
		@all_users.each do |a_user|
			if count_sums.key?(a_user.ministry.name)
				count_sums[a_user.ministry.name] += a_user.annual_counts.map { |c| Count.find(c) }.select{ |c| c.year == year}[0].count
			else
				count_sums[a_user.ministry.name] = a_user.annual_counts.map { |c| Count.find(c) }.select{ |c| c.year == year}[0].count
			end
		end

		@all_ministry_names.each do |name|
			if !count_sums.key?(name)
				count_sums[name] = 0
			end
		end
		@group1_sum = count_sums[@group1]
		group1_model.descendants.each do |group|
			@group1_sum += count_sums[group.name]
		end
		group1_model.ancestors.each do |group|
			@group1_sum += count_sums[group.name]
		end
		@group2_sum = count_sums[@group2]
		group2_model.descendants.each do |group|
			@group2_sum += count_sums[group.name]
		end
		group2_model.ancestors.each do |group|
			@group2_sum += count_sums[group.name]
		end
		@title_text = @group1 + " vs. " + @group2
		@y_axis_max = [@group1_sum, @group2_sum].max + 5
		respond_to do |format|
			format.js
		end
	end
end
