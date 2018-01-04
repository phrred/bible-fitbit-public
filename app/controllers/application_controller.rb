class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :verify_oath_user
  before_action :verify_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    @pending_challenge_requests ||= ChallengeReadEntry.where(user: @current_user, accepted: nil)
    @current_user
  end

  def verify_user
    if request.user_agent =~ /Mobile|webOS/
      redirect_to mobile_path
      return
    end
    if not current_user()
      redirect_to controller: 'login', action: 'show'
    end
  end

  def current_oath_user
    @current_oath_user ||= OathUser.find(session[:oath_user_id]) if session[:oath_user_id]
  end

  def verify_oath_user
    if request.user_agent =~ /Mobile|webOS/
      redirect_to mobile_path
      return
    end
    if not current_oath_user()
      redirect_to controller: 'login', action: 'show'
    end
  end

end
