class LoginController < ApplicationController
	skip_before_action :verify_user, only: [:show]
	def show
		p "here in the login controller"
	end
end
