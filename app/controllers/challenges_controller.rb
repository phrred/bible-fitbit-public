class ChallengesController < ApplicationController
	def show
	  	@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse
		session_email = session[:email]
		@user = User.where(email: session_email).take
		@peer_class = @user.peer_class.name
		@other_peers = Group.where(group_type: "peer_class").order(:name).pluck(:name)
		@other_peers.delete(@user.peer_class.name)
		@new_challenge = Challenge.new()

		@ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)

		@gender = @user.gender ? "brothers" : "sisters"
		selected_ministry = @user.ministry
		@grouping_options = []

		while selected_ministry != nil
			@ministry_names.delete(selected_ministry.name)
			@grouping_options << selected_ministry
			selected_ministry = selected_ministry.parent
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
		emails = User.all.order(:lifetime_count_id).pluck(:email)
		your_rank = emails.index(@user.email)
		@your_ranking = your_rank.to_f/emails.size()
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
		show()
		respond_to do |format|
			format.js
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
end