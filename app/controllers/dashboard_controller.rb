class DashboardController < ApplicationController
	include ApplicationHelper

	def config_dashboard
		@_ = Challenge.new()
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		@all_ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		last_read_entry = ReadEvent.where(user_id: session[:user_id]).order("updated_at DESC").first
		if last_read_entry != nil
			@last_book_read = last_read_entry.chapter.book
		else
			@last_book_read = "Genesis"
		end
	end
	def show
		config_dashboard()
		@group1 = Group.take(1)[0].name
		@group2 = @group1
		@title_text = @group1 + " vs. " + @group2
		@y_axis_max = 10

		@user_shadowings = UserShadowing.where(user_id: @user)
		chapters_read = 0
		@user_shadowings.each do |shadows|
			chapters_read += shadows.shadowing.count()
		end
		@percentage_of_bible = chapters_read.to_f / bible_chapter_count

		last_read_entry = ReadEvent.where(user_id: session[:user_id]).order("updated_at DESC").first
		if last_read_entry != nil
			@last_book_read = last_read_entry.chapter.book
			last_book_shadowings = @user_shadowings.where(book: @last_book_read).take
			last_book_chapters_read = last_book_shadowings.shadowing.count()
			
			book_chapter_count = Chapter.where(book: @last_book_read).count()
			@percentage_of_last_book = last_book_chapters_read.to_f / book_chapter_count * 100.0
		else
			@percentage_of_last_book = "You need to read the bible"
		end
		see_book_percent_read()
		how_many_reps()
		set_up_pace_chart()
 		generate_your_percentile()
 		generate_top_10()

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

		@initial_repetition_labels = Array.new(@book_repetitions[@last_book_read].size-1){|i| "Chapter " + String(i+1)}
		@initial_repetition_labels.unshift(@last_book_read)
	end

	def generate_top_10
		@top_10 = Array.new(10)
		top_10_ids = Count.where(year: Date.today.year).order(:count).reverse_order.limit(10).pluck(:id)
		User.all.each do |user|
			user.annual_counts.each do |count_id|
				rank = top_10_ids.index(count_id)
				if rank != -1
					@top_10[rank] = {"gender"=>user.gender,"count"=>Count.where(id: count_id).take.count}
					break
				end
			end
		end
	end

	def generate_your_percentile
		count_ids = Count.where(year: 0).order(:count).pluck(:id)
		your_rank = count_ids.index(@user.lifetime_count.id)
		@your_ranking_percentile = your_rank*100.0/([1,count_ids.size() - 1].max)
		@next_percentile = @your_ranking_percentile == 100.0 ? 100.0 : (@your_ranking_percentile/10+1).floor*10
		@next_percentile_id = (@next_percentile/100*([1,count_ids.size() - 1].max)).floor
		@next_ten_percent = Count.where(id: count_ids[@next_percentile_id]).pluck(:count)
	end

	def see_book_percent_read
		@book_percentages = {}
		bible_books.each do |book|
			chapters_read = UserShadowing.where(user_id: @user, book: book).take.shadowing.count
			@book_percentages[book] = chapters_read.to_f/Chapter.where(book: book).count() * 100.0
		end
	end

	def how_many_reps
		@x_axis_max = 0
		@user_readings = ReadEvent.where(user: @user).group("chapter_id").count
		@book_repetitions = {}
		bible_books.each do |book|
			@book_repetitions[book] = []
			Chapter.where(book: book).pluck(:id).each do |id|
				if !@user_readings.nil? and @user_readings.key?id
					if @user_readings[id] > @x_axis_max
						@x_axis_max = @user_readings[id]
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
			read_event_date = read_event.read_at.beginning_of_week.to_date
			if @your_pace.key?(read_event_date)
				@your_pace[read_event_date] += 1
			else
				@your_pace[read_event_date] = 1
			end
		end
		while @your_pace.keys.min < date
			@your_pace[date] = 0
			date = date - 7
		end
		p(@your_pace.keys)
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
