class ProfileController < ApplicationController
	def show
		session_email = session[:email]

		@ministry_names = Group.where(group_type: "ministry").pluck(:name)
		@classes = Group.where(group_type: "peer_class").pluck(:name)
		
		@user = User.where(email: session_email).take
		if @user != nil
			#redirect_to root_path
			@user_ministry = @user.ministry
			@user_peer_class = @user.peer_class
			@user_name = @user.name
			@user_email = @user.email
			@user_gender = if @user.gender then "male" else "female" end
		else
			@user = User.new
		end
	end

	def update 
		session_email = session[:email]
		@user = User.where(email: session_email).take

		input = params[:user]
		input_name = input[:name]
		input_ministry = Group.where(group_type: "ministry", name: input[:ministry]).take
		input_peer_class = Group.where(group_type: "peer_class", name: input[:peer_class]).take
		input_gender = if input[:gender] == "male" then true else false end

		p "peer_class"
		p input_peer_class.name

		p "ministry"
		p input_ministry.name

		if @user != nil
			original = User.find_by(email: session_email)
			p "original===="
			p original
			p "happening here"
			# remove from original groups (regardless of change to keep simpler)
			input_ministry.members.delete(@user)
			input_peer_class.members.delete(@user)

			original.update!(
				name: input_name,
				email: session_email,
				gender: input_gender,
				ministry: input_ministry,
				peer_class: input_peer_class
			)
		else
			new_lifetime = Count.create(year: 0, count: 0)
			@user = User.create!(
				name: input_name,
				email: session_email,
				gender: input_gender,
				peer_class: input_peer_class,
				ministry: input_ministry,
				lifetime_count: new_lifetime
			)
		end

		# add association for user to be considered a member of the specified ministry and peer class
		input_ministry.members << @user
		input_peer_class.members << @user

		p "final ministry"
		p @user.ministry
		p "final peer clas"
		p @user.peer_class

		redirect_to action: "show", controller: "profile"
	end
end
