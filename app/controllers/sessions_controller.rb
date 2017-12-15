class SessionsController < ApplicationController
  def create
  	auth_hash = request.env['omniauth.auth']

    hd = nil
    if auth_hash.extra && auth_hash.extra.id_info
      hd = auth_hash.extra.id_info.hd
    end

    if hd != "gpmail.org"
      # Hosted domain doesn't match
      flash[:error] = 'Only gpmail emails allowed'
      redirect_to root_path
    else
	    user = OathUser.from_omniauth(auth_hash)
	    session[:user_id] = user.id
	    redirect_to root_path
	end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
