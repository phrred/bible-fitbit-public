class HomeController < ApplicationController
  def show
		@user = session[:user_id]
		if not @user
			redirect_to controller: 'login', action: 'show'
		end
  end
end
