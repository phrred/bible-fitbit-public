class ChallengesController < ApplicationController
	skip_before_action :verify_authenticity_token  
	def show
		@group1 = Group.take(1)[0].name
		@group2 = @group1
		@title_text = @group1 + " vs. " + @group2
		@comparison_data = {}
		@all_users = User.all
		year = Date.today.to_time.strftime('%Y').to_i
		@all_users.each do |a_user|
			if @comparison_data.key?(a_user.ministry.name)
				@comparison_data[a_user.ministry.name] += a_user.annual_counts.map { |c| Count.find(c) }.select{ |c| c.year == year}[0].count
			else
				@comparison_data[a_user.ministry.name] = a_user.annual_counts.map { |c| Count.find(c) }.select{ |c| c.year == year}[0].count
			end
		end

	  	@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		@peer_class = @user.peer_class.name
		@other_peers = Group.where(group_type: "peer_class").order(:name).pluck(:name)
		@new_challenge = Challenge.new()

	  	@outstanding_challenges = ChallengeReadEntry.where(user: @user, accepted: nil)


		@ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		@all_ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)

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
			ChallengeReadEntry.where(user: @user, accepted: true).each do |challenge_read_entry|
					Challenge.where("id = ? AND winner IS NOT NULL", challenge_read_entry.challenge).each do |challenge|
						@old_challenges << challenge
					end
			end
		end

		grab_current_challenges()

	end

	def create
		@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		@peer_class = @user.peer_class.name
		@other_peers = Group.where(group_type: "peer_class").order(:name).pluck(:name)
		@new_challenge = Challenge.new()
		@ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		@all_ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
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
		@current_challenges = []
		@sender_scores = []
		@receiver_scores = []
		@chart_labels = {}
		@x_axis_labels = []
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		monday = Date.today.beginning_of_week
		@chart_data = {}
		ChallengeReadEntry.where(user: @user, accepted: true).each do |challenge_read_entry|
			challenge = challenge_read_entry.challenge
			initialize_chart_data(challenge)
			sender_group = challenge.sender_ministry
			sender_number = 0
			receiver_number = 0
			sender_sum = 0
			receiver_sum = 0
			entries = ChallengeReadEntry.where(challenge: challenge)
			if entries != nil
				entries.each do |entry|
					if is_user_in_group(@user, sender_group)
						entry[:read_at].each do |date|
							date = date.strftime("%B %d, %Y")
							@chart_data[challenge][date][0] += 1
						end
						sender_number = sender_number + 1
						sender_sum = sender_sum + entry[:chapters].size
					else
						entry[:read_at].each do |date|
							date = date.strftime("%B %d, %Y")
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
	end

	def create_challenge_read_entry(user, challenge)
		ChallengeReadEntry.create!(
			challenge: challenge,
			user: user)
	end

	def create_challenge
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		challenge =  params[:challenge]

		sender_class = challenge[:sender_peer] ? @user.peer_class : nil
		sender_gender = challenge[:sender_gender] != "" ? @user.gender : nil
		sender_ministry = Group.where(group_type: "ministry", name: challenge[:sender_ministry]).take
		receiver_class = Group.where(group_type: "peer_class", name: challenge[:receiver_peer]).take
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
			receiver_peer_id: receiver_class,
			valid_books: valid_books,
			start_time: Date.today.beginning_of_week
		)
		sender_recipients = []
		User.where(ministry: sender_ministry).each do |user|
			sender_recipients << user
		end
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
		user_challenge_read_entry = ChallengeReadEntry.where(challenge: new_challenge, user: @user)[0]
		# user_challenge_read_entry.update(accepted: true)
		show()
		respond_to do |format|
			format.js
		end
		redirect_to challenges_path
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

	def accept_challenge
		challenge_request = ChallengeReadEntry.where(id: params[:challenge_request])
		challenge_request.update(
			accepted: true)
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
	  	@outstanding_challenges = ChallengeReadEntry.where(user: @user, accepted: nil)
		grab_current_challenges()

		respond_to do |format|
			format.js
		end
	end
	def reject_challenge
		challenge_request = ChallengeReadEntry.where(id: params[:challenge_request])
		challenge_request.update(
			accepted: false)
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
	  	@outstanding_challenges = ChallengeReadEntry.where(user: @user, accepted: nil)

		respond_to do |format|
			format.js
		end
	end
end