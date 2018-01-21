class ChallengesController < ApplicationController
	skip_before_action :verify_authenticity_token  
	def show
		@group1 = Group.take(1)[0].name
		@group2 = @group1
		@title_text = @group1 + " vs. " + @group2
		@all_users = User.all
		year = Date.today.to_time.strftime('%Y').to_i

	  	@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		@peer_class = @user.peer_class.name
		@other_peers = Group.where(group_type: "peer_class").order(:name).pluck(:name)
		@new_challenge = Challenge.new()

	  	@outstanding_challenges = ChallengeReadEntry.where(user: @user, accepted: nil)


		@ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
		@all_ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)


		@gender = @user.gender ? "brothers" : "sisters"
		selected_ministry = @user.ministry
		@grouping_options = [selected_ministry]
		# selected_ministry.ancestors.each do |ministry|
		# 	@ministry_names.delete(ministry.name)
		# 	@grouping_options << ministry
		# end

		# @ministry_names.delete(selected_ministry.name)
		# selected_ministry.descendants.each do |ministry|
		# 	@ministry_names.delete(ministry.name)
		# end

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

	def challenges2
		# test_user = User.create!(
		# 	email: "test1@gmail.com",
		# 	name: "test1",
		# 	ministry: Group.take(),
		# 	peer_class: Group.take(),
		# 	lifetime_count: Count.take()
		# 	)

      	@new_challenge = Challenge.new()
		@all_da_users = User.where.not(id: session[:user_id])
		@books = Chapter.order("created_at DESC").all.uniq{ |c| c.book }.reverse
	end

	def create_challenge_read_entry(user, challenge)
		ChallengeReadEntry.create!(
			challenge: challenge,
			user: user)
	end

	def create2
		@new_challenge = Challenge.new()
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		challenge =  params[:challenge]
		p(challenge)

		sender_class = nil
		sender_gender = nil
		sender_ministry = nil
		receiver_class = nil
		receiver_ministry = nil
		receiver_gender = nil
		challenge[:valid_books].slice!(0)
		valid_books = challenge[:valid_books].size > 0 ? challenge[:valid_books] : nil
		your_teammates = challenge[:your_team]
		your_teammates.slice!(0)
		your_teammates.append(user_id)
		opp_teammates = challenge[:opp_team]
		opp_teammates.slice!(0)

		if opp_teammates.size() == 0
			@warning = "No one on the other team"
			challenges2()
			respond_to do |format|
				format.js
			end
			return	
		end

		p(your_teammates & opp_teammates)

		if your_teammates & opp_teammates != []
			on_both_teams = your_teammates & opp_teammates
			on_both_teams = on_both_teams.map { |u| User.find(u)}
			on_both_teams = on_both_teams.map {|u| u.name}
			@warning = "Some people are on both teams" + on_both_teams.join(',')
			challenges2()
			respond_to do |format|
				format.js
			end
			return			
		end
		title = challenge[:title]

		start_date = Date.today
		if start_date.cwday > 3
			start_date = start_date + 7
		end
		start_date = start_date.beginning_of_week

		prev_challenge = Challenge.where(
			sender_ministry: sender_ministry,
			receiver_ministry: receiver_ministry,
			sender_gender: sender_gender,
			receiver_gender: receiver_gender,
			sender_peer: sender_class,
			receiver_peer_id: receiver_class,
			valid_books: valid_books,
			start_time: start_date,
			title: title,
			winner: nil,
			your_team: your_teammates,
			opp_team: opp_teammates
			)

		if !prev_challenge.empty?
			@warning = "This challenge already exists"
			challenges2()
			respond_to do |format|
				format.js
			end
			return
		end

		new_challenge = Challenge.create!(
			sender_ministry: sender_ministry,
			receiver_ministry: receiver_ministry,
			sender_gender: sender_gender,
			receiver_gender: receiver_gender,
			sender_peer: sender_class,
			receiver_peer_id: receiver_class,
			valid_books: valid_books,
			start_time: start_date,
			end_time: start_date + 5,
			title: title,
			your_team: your_teammates,
			opp_team: opp_teammates
			)
		sender_recipients = your_teammates.map { |u| User.find(u) }
		
		sender_recipients.each do |user|
			create_challenge_read_entry(user, new_challenge)
		end

		receiver_recipients = opp_teammates.map {|u| User.find(u) }

		receiver_recipients.each do |user|
			create_challenge_read_entry(user, new_challenge)
		end
		user_challenge_read_entry = ChallengeReadEntry.where(challenge: new_challenge, user: @user)[0]
		user_read_entries = ReadEvent.where(user: @user).where("read_at >= ? AND read_at < ?",start_date, start_date + 5)
		user_read_entries.each do |read_event|
			if valid_books.nil?
				user_challenge_read_entry.chapters << read_event.chapter.id
				user_challenge_read_entry.read_at << read_event.read_at
			else
				if valid_books.include?(read_event.chapter.book)
					user_challenge_read_entry.chapters << read_event.chapter.id
					user_challenge_read_entry.read_at << read_event.read_at
				end
			end
		end

		user_challenge_read_entry.update(accepted: true)
		user_challenge_read_entry.save
		show()
		redirect_to challenges_path
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
		# selected_ministry.ancestors.each do |ministry|
		# 	@ministry_names.delete(ministry.name)
		# 	@grouping_options << ministry
		# end

		# @ministry_names.delete(selected_ministry.name)
		# selected_ministry.descendants.each do |ministry|
		# 	@ministry_names.delete(ministry.name)
		# end

	end

	def initialize_chart_data(challenge)
		@challenge_users[challenge] = []
		@challenge_users[challenge].push(challenge.your_team.map{|u| User.find(u).name})
		@challenge_users[challenge].push(challenge.opp_team.map{|u| User.find(u).name})
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
		@my_contributions = {}
		@chart_data = {}
		@challenge_users = {}
		ChallengeReadEntry.where(user: @user, accepted: true).each do |challenge_read_entry|
			challenge = challenge_read_entry.challenge
			@my_contributions[challenge] = challenge_read_entry.chapters.size
			if challenge.winner.nil?
				initialize_chart_data(challenge)
				sender_group = challenge.your_team
				sender_number = 0
				receiver_number = 0
				sender_sum = 0
				receiver_sum = 0
				entries = ChallengeReadEntry.where(challenge: challenge, accepted: true)
				if entries != nil
					entries.each do |entry|
						if !entry.nil?
							if sender_group.include?(entry.user.id)
								entry[:read_at].each do |date|
									@chart_data[challenge][date][0] += 1
								end
								sender_number = sender_number + 1
								sender_sum = sender_sum + entry[:chapters].size
							else
								entry[:read_at].each do |date|
									@chart_data[challenge][date][1] += 1
								end
								receiver_number = receiver_number + 1
								receiver_sum = receiver_sum + entry[:chapters].size
							end
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
					@chart_data[challenge][key] = [(array[0]/sender_number).round(2), (array[1]/receiver_number).round(2)]

				end
				@sender_scores << (sender_sum/sender_number).round(2)
				@receiver_scores << (receiver_sum/receiver_number).round(2)
				@current_challenges << challenge
			end
		end

		@chart_data.keys.each do |challenge|
			@chart_labels[challenge] = {}
			@chart_labels[challenge]["x_labels"] = []
			@chart_labels[challenge]["y0_name"] = challenge.your_team.include?(user_id) ? "Your Team" : "Opp Team"
			@chart_labels[challenge]["y1_name"] = challenge.opp_team.include?(user_id) ? "Your Team" : "Opp Team"
			@chart_labels[challenge]["y0_data"] = []
			@chart_labels[challenge]["y1_data"] = []
			@chart_labels[challenge]["title"] = challenge.title

			@chart_data[challenge].keys.each do |date|
				@chart_labels[challenge]["x_labels"] << date.to_date
			end
			@chart_data[challenge].values.each do |value_array|
				@chart_labels[challenge]["y0_data"] << value_array[0]
				@chart_labels[challenge]["y1_data"] << value_array[1]
 			end
 		end
	end

	def create_challenge
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
		challenge =  params[:challenge]

		sender_class = challenge[:sender_peer] == "true"? @user.peer_class : nil
		sender_gender = challenge[:sender_gender] != "" ? @user.gender : nil
		sender_ministry = Group.where(name: challenge[:sender_ministry]).take
		receiver_class = Group.where(name: challenge[:receiver_peer]).take
		receiver_ministry = Group.where(name: challenge[:receiver_ministry]).take
		receiver_gender = challenge[:receiver_gender].size == 2 ? challenge[:receiver_gender][1] == "true": nil
		challenge[:valid_books].slice!(0)
		valid_books = challenge[:valid_books].size > 0 ? challenge[:valid_books] : nil
		title = challenge[:title]

		if sender_ministry == receiver_ministry
			if sender_class == receiver_class
				if sender_gender == receiver_gender
					@warning = "You cannot challenge yourself"
					create()
					respond_to do |format|
						format.js
					end
					return
				end
			end
		end

		start_date = Date.today
		if start_date.cwday > 3
			start_date = start_date + 7
		end
		start_date = start_date.beginning_of_week

		prev_challenge = Challenge.where(
			sender_ministry: sender_ministry,
			receiver_ministry: receiver_ministry,
			sender_gender: sender_gender,
			receiver_gender: receiver_gender,
			sender_peer: sender_class,
			receiver_peer_id: receiver_class,
			valid_books: valid_books,
			start_time: start_date,
			title: title,
			winner: nil
			)

		if !prev_challenge.empty?
			@warning = "This challenge already exists"
			create()
			respond_to do |format|
				format.js
			end
			return
		end
		new_challenge = Challenge.create!(
			sender_ministry: sender_ministry,
			receiver_ministry: receiver_ministry,
			sender_gender: sender_gender,
			receiver_gender: receiver_gender,
			sender_peer: sender_class,
			receiver_peer_id: receiver_class,
			valid_books: valid_books,
			start_time: start_date,
			end_time: start_date + 5,
			title: title
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
		User.where(ministry: receiver_ministry).each do |user|
			receiver_recipients << user
		end
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
		user_read_entries = ReadEvent.where(user: @user).where("read_at >= ? AND read_at < ?",start_date, start_date + 5)
		user_read_entries.each do |read_event|
			if valid_books.nil?
				user_challenge_read_entry.chapters << read_event.chapter.id
				user_challenge_read_entry.read_at << read_event.read_at
			else
				if valid_books.include?(read_event.chapter.book)
					user_challenge_read_entry.chapters << read_event.chapter.id
					user_challenge_read_entry.read_at << read_event.read_at
				end
			end
		end

		user_challenge_read_entry.update(accepted: true)
		user_challenge_read_entry.save
		new_challenge.update(your_team: sender_recipients.map {|u| u.id})
		new_challenge.update(opp_team: sender_recipients.map {|u| u.id})
		show()
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
		challenge_request = ChallengeReadEntry.where(id: params[:challenge_request]).take
		challenge = challenge_request.challenge
		user_id = session[:user_id]
		@user = User.where(id: user_id).take
	  	@outstanding_challenges = ChallengeReadEntry.where(user: @user, accepted: nil)
		user_read_entries = ReadEvent.where(user: @user).where("read_at >= ? and read_at < ?",challenge[:start_time], challenge[:end_time])
		user_read_entries.each do |read_event|
			if challenge[:valid_books].nil? || challenge[:valid_books].empty?
				challenge_request.chapters << read_event.chapter.id
				challenge_request.read_at << read_event.read_at
			else
				if challenge[:valid_books].include?(read_event.chapter.book)
					challenge_request.chapters << read_event.chapter.id
					challenge_request.read_at << read_event.read_at
				end
			end
		end
		challenge_request.update(accepted: true)
		challenge_request.save

		@new_challenge = Challenge.new()
		grab_current_challenges()

		respond_to do |format|
			format.js
		end
	end
	def reject_challenge
		@new_challenge = Challenge.new()
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