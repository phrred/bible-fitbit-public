class DashboardController < ApplicationController
	include ApplicationHelper

	def config_dashboard
		@_ = Challenge.new()
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		@all_groups = group_by_group_type()
		last_read_entry = ReadEvent.where(user_id: session[:user_id]).order("updated_at DESC").first
		if last_read_entry != nil
			@last_book_read = last_read_entry.chapter.book
		else
			@last_book_read = "Genesis"
		end
	end

	def show
		config_dashboard()

    @year = Time.now.year
    @lifetime_count = @user.lifetime_count.count
    @annual_count = @user.annual_counts.map { |c| Count.find(c) }.select{ |c| c.year == @year}[0].count

    @beginning_of_week = Date.today.beginning_of_week
    @count = ReadEvent.where("user_id=? AND read_at >= ?", @user.id, @beginning_of_week).count

    group1_model = current_user().ministry
    @group1 = group1_model.name
    if @group1.downcase == "berkeley college"
      group2_model = Group.where(name: "Berkeley Praxis").take
    else
      group2_model = Group.where(name: "Berkeley College").take
    end
    @group2 = group2_model.name

    @group1_average = group_average(group1_model, @group1)
    @group2_average = group_average(group2_model, @group2)

	@title_text = @group1 + " vs. " + @group2
	@y_axis_max = 10

	@user_shadowings = UserShadowing.where(user_id: @user)
	chapters_read = 0
	@user_shadowings.each do |shadows|
		chapters_read += shadows.shadowing.uniq.count()
	end
	@percentage_of_bible = chapters_read.to_f / bible_chapter_count

	last_read_entry = ReadEvent.where(user_id: session[:user_id]).order("updated_at DESC").first
	if last_read_entry != nil
		@last_book_entered = last_read_entry.chapter.book
		last_book_shadowings = @user_shadowings.where(book: @last_book_entered).take
		last_book_chapters_read = last_book_shadowings.shadowing.uniq.count()

		book_chapter_count = Chapter.where(book: @last_book_entered).count()
		@percentage_of_last_book = last_book_chapters_read.to_f / book_chapter_count * 100.0
	else
		@percentage_of_last_book = 0
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
		(@your_pace[pace_chart_start] / 7.0).round(2),
		(@your_pace[pace_chart_start + 7] / 7.0).round(2),
		(@your_pace[pace_chart_start + 14] / 7.0).round(2),
		(@your_pace[pace_chart_start + 21] / 7.0).round(2)]

		@initial_repetition_labels = Array.new(@book_repetitions[@last_book_read].size-1){|i| "Chapter " + String(i+1)}
		@initial_repetition_labels.unshift(@last_book_read)
	end

	def generate_top_10
    @beginning_of_week = Date.today.beginning_of_week
    @beginning_of_month = Date.today.beginning_of_month
    @top_10_week = Array.new()
    @top_10_month = Array.new()

    top_10_week_id_count = ReadEvent.where("read_at >= ?", @beginning_of_week).group(:user_id).count.sort_by{|uid, week_count| week_count}.reverse[0...10]
    top_10_week_id_count.each do |uid, count|
      user = User.find(uid)
      entry = {"gender" => user.gender, "count" => count, "ministry" => user.ministry.name}
      @top_10_week.append(entry)
    end

    top_10_month_id_count = ReadEvent.where("read_at >= ?", @beginning_of_month).group(:user_id).count.sort_by{|uid, month_count| month_count}.reverse[0...10]
    top_10_month_id_count.each do |uid, count|
      user = User.find(uid)
      entry = {"gender" => user.gender, "count" => count, "ministry" => user.ministry.name}
      @top_10_month.append(entry)
    end

		@top_10 = Array.new(10)
		top_10_ids = Count.where(year: Date.today.year).order(:count).reverse_order.limit(10).pluck(:id)
		User.all.each do |user|
			user.annual_counts.each do |count_id|
				rank = top_10_ids.index(count_id)
				if !rank.nil? && rank != -1
					@top_10[rank] = {"gender"=>user.gender,"count"=>Count.where(id: count_id).take.count, "ministry"=>user.ministry.name}
					break
				end
			end
		end
	end

	def generate_your_percentile
		count_ids = Count.where(year: Date.today.year).order(:count).pluck(:id)
		user_annual_count = @user.annual_counts.map { |c| Count.find(c) }.select { |count| count.year == Time.current.year }
		your_rank = count_ids.index(user_annual_count[0].id)
        if !(your_rank.is_a? Integer)
          	annual_count = Count.create!(count: 0, year: Time.current.year)
  			count_ids = Count.where(year: Date.today.year).order(:count).pluck(:id)
  			@user.annual_counts << annual_count.id
  			@user.save
			your_rank = count_ids.index(@user.annual_counts[-1])
        end
		@your_ranking_percentile = your_rank*100.0/([1,count_ids.size() - 1].max)
		@next_percentile = @your_ranking_percentile == 100.0 ? 100.0 : (@your_ranking_percentile/10+1).floor*10.0
		@next_percentile_id = (@next_percentile/100.0*([1.0, count_ids.size() - 1.0].max)).floor
		@next_ten_percent = Count.where(id: count_ids[@next_percentile_id]).pluck(:count)
		@your_annual_count = user_annual_count[0].count
	end

	def see_book_percent_read
		@book_percentages = {}
		bible_books.each do |book|
			chapters_read = UserShadowing.where(user_id: @user, book: book).take.shadowing.uniq.count
			@book_percentages[book] = (chapters_read.to_f/Chapter.where(book: book).count() * 100.0).round(2)
		end
	end

	def how_many_reps
		@y_axis_max = 0
		@user_readings = ReadEvent.where(user: @user).group("chapter_id").count
		@book_repetitions = {}
		bible_books.each do |book|
			@book_repetitions[book] = []
			Chapter.where(book: book).pluck(:id).each do |id|
				if !@user_readings.nil? and @user_readings.key?id
					if @user_readings[id] > @y_axis_max
						@y_axis_max = @user_readings[id]
					end
					@book_repetitions[book] << @user_readings[id]
				else
					@book_repetitions[book] << 0
				end
			end
			@book_repetitions[book].unshift(@book_repetitions[book].min)
		end
		@y_axis_max += 5
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
		@suggested_max = @your_pace.values.max/7 + 5
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
			(@your_pace[pace_chart_start] / 7.0).round(2),
			(@your_pace[pace_chart_start + 7] / 7.0).round(2),
			(@your_pace[pace_chart_start + 14] / 7.0).round(2),
			(@your_pace[pace_chart_start + 21] / 7.0).round(2)]

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
			(@your_pace[pace_chart_start] / 7.0).round(2),
			(@your_pace[pace_chart_start + 7] / 7.0).round(2),
			(@your_pace[pace_chart_start + 14] / 7.0).round(2),
			(@your_pace[pace_chart_start + 21] / 7.0).round(2)]

		respond_to do |format|
			format.js
		end
	end

  def group_average(group_model, group_name)
		year = Date.today.to_time.strftime('%Y').to_i
    sum = 0
    count = 0
    if group_model.nil?
      if group_name == "Brothers"
        users = User.where(gender: true)
      else
        users = User.where(gender: false)
      end

      if !users.nil?
        users.each do |user|
        	annual_count = user.annual_counts.map { |c| Count.find(c) }.select{ |c| c.year == year}[0]
        	if !annual_count.nil?
	          sum += annual_count.count
	      end
        end
        count += users.size
      end
    else
      groups = [group_model] + group_model.descendants
      groups.each do |g|
        users = User.where(ministry: g.id)
        if !users.nil?
          users.each do |user|
          	annual_count = user.annual_counts.map { |c| Count.find(c) }.select{ |c| c.year == year}[0]
          	if !annual_count.nil?
	            sum += annual_count.count
	        end
          end
          count += users.size
        end
      end
    end
    sum.to_f / count
  end

	def comparison_values
		other_params = params[:challenge]
		if other_params[:sender_ministry] == "Brothers" || other_params[:sender_ministry] == "Sisters"
			@group1 = other_params[:sender_ministry]
		else
			group1_model = Group.where(name: other_params[:sender_ministry])[0]
			@group1 = group1_model.name
		end
		if other_params[:receiver_ministry] == "Brothers" || other_params[:receiver_ministry] == "Sisters"
			@group2 = other_params[:receiver_ministry]
		else
			group2_model = Group.where(name: other_params[:receiver_ministry])[0]
			@group2 = group2_model.name
		end
		year = Date.today.to_time.strftime('%Y').to_i
		@title_text = @group1 + " vs. " + @group2
		@group1_average = group_average(group1_model, @group1)
		@group1_average = @group1_average.nan? ? 0.0 : @group1_average

		@group2_average = group_average(group2_model, @group2)
		@group2_average = @group2_average.nan? ? 0.0 : @group2_average
		@y_axis_max = [@group1_average, @group2_average].max + 5
		respond_to do |format|
			format.js
		end
	end

	def group_by_group_type()
		ministry = Group.where(group_type: "ministry").order(:name).pluck(:name)
		state = Group.where(group_type: "state").order(:name).pluck(:name)
		region = Group.where(group_type: "region").order(:name).pluck(:name)
		grouped_options = [["Ministry", ministry], ["State", state], ["Region", region], ["Gender", ["Brothers", "Sisters"]]]
		return grouped_options
	end

	 def resetBook
    @displayed_book = params[:book]
    user = User.find(session[:user_id])
    user_shadowing = UserShadowing.find_by(user: user, book: @displayed_book)
    if user_shadowing != nil
      user_shadowing.shadowing = []
      user_shadowing.save
    end
  end

  def resetBible
    user = User.find(session[:user_id])
    user_shadowings = UserShadowing.where(user: user)
    user_shadowings.each { |s|
      s.shadowing = []
      s.save
    }
  end

end
