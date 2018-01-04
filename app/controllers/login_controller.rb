class LoginController < ApplicationController
	skip_before_action :verify_user, only: [:show]
	skip_before_action :verify_oath_user, only: [:show]
	def show
		redirect_to mobile_path
		if session[:user_id] != nil
			redirect_to dashboard_path
		end
	end
end
