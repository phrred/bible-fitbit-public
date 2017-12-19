class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :verify_user

  def current_user
    p "user email"
    p session[:user_email]
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    #@current_user ||= OathUser.find(session[:oath_user_id]) if session[:oath_user_id]
  end

  def verify_user
	if not current_user()
		redirect_to controller: 'login', action: 'show'
	end
  end

end
