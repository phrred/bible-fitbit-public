class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :verify_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @pending_challenge_requests ||= ChallengeReadEntry.where(user: @current_user, accepted: nil)
  end

  def verify_user
	if not current_user()
		redirect_to controller: 'login', action: 'show'
	end
  end

end
