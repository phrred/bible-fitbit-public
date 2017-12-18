class ChallengesController < ApplicationController
	skip_before_action :verify_authenticity_token  
	def show
		@group1 = Group.take(1)[0].name
		@group2 = @group1
		@title_text = @group1 + " vs. " + @group2
		@comparison_sums = User.left_outer_joins(:annual_count).group(:ministry).sum("count")
	  	@comparison_data = {}

	  	@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse
		session_email = session[:email]
		@user = User.where(email: session_email).take
		@peer_class = @user.peer_class.name
		@other_peers = Group.where(group_type: "peer_class").order(:name).pluck(:name)
		@new_challenge = Challenge.new()

	  	@outstanding_challenges = ChallengeReadEntry.where(user: @user, accepted: nil)
	  	p(@outstanding_challenges)


		@ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		@all_ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		@comparison_sums.keys.each do |group|
			@comparison_data[group.name] = @comparison_sums[group]
		end
		@all_ministry_names.each do |name|
			if !@comparison_data.key?(name)
				@comparison_data[name] = 0
			end
		end

		@gender = @user.gender ? "brothers" : "sisters"
		selected_ministry = @user.ministry
		@grouping_options = [selected_ministry]
		selected_ministry.ancestors.each do |ministry|
			@ministry_names.delete(ministry.name)
			@grouping_options << ministry
		end

		@ministry_names.delete(selected_ministry.name)
		selected_ministry.descendants.each do |ministry|
			@ministry_names.delete(ministry.name)
		end

		@old_challenges = []
		monday = Date.today.beginning_of_week
		@grouping_options.each do |ministry|
			Challenge.where("(sender_ministry_id = ? OR receiver_ministry_id = ?) AND winner IS NOT NULL", ministry, ministry).each do |challenge|
					@old_challenges << challenge
			end
		end
		# test = Chapter.find(1,2,3).pluck(:id)

		# ChallengeReadEntry.create!(
		# 	user: @user,
		# 	chapters: test,
		# 	challenge: Challenge.find(2),
		#   	read_at: [Date.today.beginning_of_week, Date.today.beginning_of_week, Date.today.beginning_of_week])

		@chart_challenge_id = Challenge.take(1).pluck(:id)[0]
		@chart_challenge = Challenge.take(1)[0]
		p("WHAT")
		# p(@chart_challenge.sender_ministry.name)
		@current_challenges = []
		@sender_scores = []
		@receiver_scores = []
		@chart_data = {}
		@chart_labels = {}
		@x_axis_labels = []
		grab_current_challenges()

		@chart_data.keys.each do |challenge|
			@chart_labels[challenge] = {}
			@chart_labels[challenge]["x_labels"] = []
			@chart_labels[challenge]["y0_name"] = challenge.sender_ministry.name
			@chart_labels[challenge]["y1_name"] = challenge.receiver_ministry.name
			@chart_labels[challenge]["y0_data"] = []
			@chart_labels[challenge]["y1_data"] = []
			@chart_labels[challenge]["title"] = challenge.sender_ministry.name + " vs. " + challenge.receiver_ministry.name + " (Total Chapters to Date on Average per Person)"

			@chart_data[challenge].keys.each do |date|
				@chart_labels[challenge]["x_labels"] << date.to_date
			end
			@chart_data[challenge].values.each do |value_array|
				@chart_labels[challenge]["y0_data"] << value_array[0]
				@chart_labels[challenge]["y1_data"] << value_array[1]
 			end
 		end
 		# p(@chart_labels[@chart_challenge]["x_labels"])
 		# p(@chart_labels[@chart_challenge]["y0_name"])
 		# p(@chart_labels[@chart_challenge]["y1_name"])
 		# p(@chart_labels[@chart_challenge]["y0_data"])
 		# p(@chart_labels[@chart_challenge]["y1_data"])
 		# p(@chart_labels[@chart_challenge]["title"])

 		generate_your_percentile()
	end

	def generate_your_percentile()
		count_ids = Count.where(year: 0).order(:count).pluck(:id)
		your_rank = count_ids.index(@user.lifetime_count.id)
		@your_ranking = your_rank*100/count_ids.size()
	end

	def initialize_chart_data(challenge)
		date = challenge.start_time
		@chart_data[challenge] = {}
		while date.saturday? != true
			@chart_data[challenge][date] = [0.0,0.0]
			date = date.tomorrow
		end
	end

	def grab_current_challenges()
		monday = Date.today.beginning_of_week
		@grouping_options.each do |ministry|
			Challenge.where("(sender_ministry_id = ? OR receiver_ministry_id = ?) AND winner IS NULL", ministry, ministry).each do |challenge|
				initialize_chart_data(challenge)
				p("HERE")
				p(@chart_data)
				sender_group = challenge.sender_ministry
				p(sender_group)
				sender_number = 0
				receiver_number = 0
				sender_sum = 0
				receiver_sum = 0
				entries = ChallengeReadEntry.where(challenge: challenge)
				if entries != nil
					entries.each do |entry|
						if is_user_in_group(@user, sender_group)
							entry[:read_at].each do |date|
								@chart_data[challenge][date][0] += 1
							end
							sender_number = sender_number + 1
							sender_sum = sender_sum + entry[:chapters].size
						else
							entry[:read_at].each do |date|
								@chart_data[challenge][date][1] += 1
							end
							receiver_number = reciever_number + 1
							receiver_sum = receiver_sum + entry[:chapters].size
						end
					end
				end
				sender_number = sender_number != 0 ? sender_number.to_f : 1.0
				receiver_number = receiver_number != 0 ? receiver_number.to_f : 1.0
				@chart_data[challenge].each do |key, array|
					if !key.friday?
						@chart_data[challenge][key.tomorrow][0] += array[0]
						@chart_data[challenge][key.tomorrow][1] += array[1]
					end
					@array = [array[0]/sender_number, array[1]/receiver_number]
				end
				@sender_scores << sender_sum/sender_number
				@receiver_scores << receiver_sum/receiver_number
				@current_challenges << challenge
			end
		end
	end

	def create_challenge_read_entry(user, challenge)
		ChallengeReadEntry.create!(
			challenge: challenge,
			user: user)
	end

	def create
		session_email = session[:email]
		@user = User.where(email: session_email).take
		challenge =  params[:challenge]
		p(challenge[:sender_peer])
		sender_class = challenge[:sender_peer] ? @user.peer_class : nil
		sender_gender = challenge[:sender_gender] != "" ? @user.gender : nil
		sender_ministry = Group.where(group_type: "ministry", name: challenge[:sender_ministry]).take
		receiver_class = Group.where(group_type: "peer_class", name: challenge[:receiver_class]).take
		receiver_ministry = Group.where(group_type: "ministry", name: challenge[:receiver_ministry]).take
		receiver_gender = challenge[:receiver_gender].size == 2 ? challenge[:receiver_gender][1] : nil
		valid_books = challenge[:valid_books].size > 0 ? challenge[:valid_books] : nil
		valid_books.slice!(0)
		new_challenge = Challenge.create!(
			sender_ministry: sender_ministry,
			receiver_ministry: receiver_ministry,
			sender_gender: sender_gender,
			receiver_gender: receiver_gender,
			sender_peer: sender_class,
			receiver_class: receiver_class,
			valid_books: valid_books,
			start_time: Date.today.beginning_of_week
		)
		sender_recipients = []
		sender_ministry.descendants.each do |ministry|
			User.where(ministry: ministry).each do |user|
				sender_recipients << user
			end
		end
		unless sender_gender.nil?
			sender_recipients = sender_recipients.select { |user| user.gender == sender_gender }
		end
		unless sender_class.nil?
			sender_recipients = sender_recipients.select { |user| user.peer_class == sender_class }
		end

		sender_recipients.each do |user|
			create_challenge_read_entry(user, new_challenge)
		end

		receiver_recipients = []
		receiver_ministry.descendants.each do |ministry|
			receiver_recipients << User.where(ministry: ministry).take
		end
		unless receiver_gender.nil?
			receiver_recipients = receiver_recipients.select { |user| user.gender == receiver_gender }
		end
		unless receiver_class.nil?
			receiver_recipients = receiver_recipients.select { |user| user.peer_class == receiver_class }
		end

		receiver_recipients.each do |user|
			create_challenge_read_entry(user, new_challenge)
		end
		show()
		respond_to do |format|
			format.js
		end
	end

	def accept_challenge
		#stub
	end

	def update_dropdown
		@ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		@new_challenge = Challenge.new()
		session_email = session[:email]
		@user = User.where(email: session_email).take
		@gender = @user.gender ? "brothers" : "sisters"
		@peer_class = @user.peer_class.name
		@other_peers = Group.where(group_type: "peer_class").order(:name).pluck(:name)

		selected_ministry = Group.where(group_type: "ministry", name: params[:your_ministry]).take

		@grouping_options = [selected_ministry]
		selected_ministry.ancestors.each do |ministry|
			@ministry_names.delete(ministry.name)
			@grouping_options << ministry
		end

		@ministry_names.delete(selected_ministry.name)
		selected_ministry.descendants.each do |ministry|
			@ministry_names.delete(ministry.name)
		end
		@ministry_names << selected_ministry.name
		respond_to do |format|
			format.js {render :js => "my_function();"}
		end
	end

	def is_user_in_group(user, group)
		if user[:peer_class] == group
			return true
		end
		user_group = user.ministry
		while user_group != nil
			if user_group == group
				return true
			end
			user_group = user_group.parent
		end
		return false
	end

	def comparison_values
		# chal = Challenge.take(1)[0]
		# session_email = session[:email]
		# @user = User.where(email: session_email).take
		# p(@user)
		# p(chal)
		# ChallengeReadEntry.create!(
		# 	user: @user,
		# 	challenge: chal)
		p(1)
		p(params)
		other_params = params[:challenge]
		p(2)
		p(other_params)
		group1_model = Group.where(name: other_params[:group1])[0]
		group2_model = Group.where(name: other_params[:group2])[0]
		p(group1_model)
		p(group2_model)
		@group1 = group1_model.name
		@group2 = group2_model.name
		p("SAM")
		@all_ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		temp_sums = User.left_outer_joins(:annual_count).group(:ministry).sum("count")
		count_sums = {}
		temp_sums.keys.each do |key|
			count_sums[key.name] = temp_sums[key]
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
		p("HERRO FRED")
		respond_to do |format|
			format.js
		end
	end

	def accept_challenge
		p("accept")
		challenge_request = ChallengeReadEntry.where(id: params[:challenge_request])
		challenge_request.update(
			accepted: true)
		session_email = session[:email]
		@user = User.where(email: session_email).take
	  	@outstanding_challenges = ChallengeReadEntry.where(user: @user, accepted: nil)

		respond_to do |format|
			format.js
		end
	end
	def reject_challenge
		p("reject")
		challenge_request = ChallengeReadEntry.where(id: params[:challenge_request])
		challenge_request.update(
			accepted: false)
		session_email = session[:email]
		@user = User.where(email: session_email).take
	  	@outstanding_challenges = ChallengeReadEntry.where(user: @user, accepted: nil)

		respond_to do |format|
			format.js
		end
	end
end