class ProfileController < ApplicationController
	def show
		#auth_hash = request.env["omniauth.auth"]
		#email = auth_hash["info"]["email"]

		user = User.where(id: 1).take
		@email = user.email
	end
end
