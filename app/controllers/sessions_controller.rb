class SessionsController < ApplicationController
	skip_before_action :verify_user, only: [:create]
  def create
  	auth_hash = request.env['omniauth.auth']

    hd = nil
    if auth_hash.extra && auth_hash.extra.raw_info
      hd = auth_hash.extra.raw_info.hd
    end

    if hd != "gpmail.org"
      # Hosted domain doesn't match
      flash[:error] = 'Only gpmail emails allowed'
      redirect_to action: "show", controller: "login"
    else
	    oath_user_iduser = OathUser.from_omniauth(auth_hash)
	    session[:oath_user_id] = oath_user.id
      session[:user_email] = oath_user.email

      user = User.where(email: oath_user.email).take
      if user
        session[:user_id] = user.id
        redirect_to action: "show", controller: "home"
      else
        redirect_to action: "new", controller: "profile"
      end
		end
  end

  def destroy
    session[:oath_user_id] = nil
    session[:user_id] = nil
    session[:user_email] = nil
    redirect_to root_path
  end
end
