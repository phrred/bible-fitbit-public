class ProfileController < ApplicationController
	def show
		session_email = session[:email]
		@user = User.where(email: session_email).take
		@user_name = @user.name
		@user_email = @user.email
	end
end
