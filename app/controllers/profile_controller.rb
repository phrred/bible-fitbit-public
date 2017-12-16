class ProfileController < ApplicationController
	def show
		session_email = session[:email]

		@ministry_names = Group.where(group_type: "ministry").pluck(:name)
		@classes = Group.where(group_type: "peer_class").pluck(:name)
		
		@user = User.where(email: session_email).take
		if @user != nil
			#redirect_to root_path
			@user_ministry = @user.ministry.name
			@user_peer_class = @user.peer_class.name
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

		if @user != nil
			@user.update!(
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

		redirect_to action: "show", controller: "profile"
	end
end
