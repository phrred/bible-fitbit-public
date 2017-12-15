class ProfileController < ApplicationController
	def show
		session_email = session[:email]
		@user = User.where(email: session_email).take
		if @user != nil
			redirect_to root_path
			@user_name = @user.name
			@user_email = @user.email
		else
			@user = User.new
		end
	end

	def create
		user =  params[:user]
		peer_class = Group.where(group_type: "peer_class", name: user[:peer_class]).take
		minstry = Group.where(group_type: "ministry", name: user[:ministry]).take
		new_lifetime = Count.create(year: 0, count: 0)
		@user = User.create!(
			name: user[:name],
			email: session[:email],
			gender: user[:gender],
			peer_class: peer_class,
			ministry: minstry,
			lifetime_count: new_lifetime
		)
		redirect_to action: "show", controller: "profile"
	end
end
