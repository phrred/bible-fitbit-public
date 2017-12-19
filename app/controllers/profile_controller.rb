class ProfileController < ApplicationController
	include ApplicationHelper
	skip_before_action :verify_user, only: [:new, :update]

  def new
    @user = User.new
		@ministry_names = Group.where(group_type: "ministry").pluck(:name)
		@classes = Group.where(group_type: "peer_class").pluck(:name)
  end

	def show
		session_email = session[:user_email]

		@ministry_names = Group.where(group_type: "ministry").pluck(:name)
		@classes = Group.where(group_type: "peer_class").pluck(:name)
		
		@user = User.where(email: session_email).take
		if @user != nil
			#redirect_to root_path
			@user_ministry = @user.ministry.name
			@user_peer_class = @user.peer_class.name
			@user_name = @user.name
			@user_email = @user.email
			@user_gender = if @user.gender then "male" else "female" end
		else
			@user = User.new
		end
	end

	def update 
    p "entered profile#update"
		session_email = session[:user_email]
		@user = User.where(email: session_email).take

		input = params[:user]
		input_name = input[:name]
		input_ministry = Group.where(group_type: "ministry", name: input[:ministry]).take
		input_peer_class = Group.where(group_type: "peer_class", name: input[:peer_class]).take
		input_gender = if input[:gender] == "male" then true else false end

		if @user != nil
      p "updating existing user"
			@user.update!(
				name: input_name,
				email: session_email,
				gender: input_gender,
				ministry: input_ministry,
				peer_class: input_peer_class
			)
      redirect_to action: "show", controller: "profile"
		else
      p "creating new user"
			year = DateTime.now.year
			new_lifetime = Count.create(year: 0, count: 0)
			current_annual = Count.create(year: DateTime.now.year, count: 0)
			@user = User.create!(
				name: input_name,
				email: session_email,
				gender: input_gender,
				peer_class: input_peer_class,
				ministry: input_ministry,
				lifetime_count: new_lifetime,
				annual_count: current_annual
			)
      session[:user_id] = @user.id

      new_shadowings = bible_books.map { |book_name|
        {
          user: @user,
          book: book_name,
          shadowing: []
        }
      }
      UserShadowing.create!(new_shadowings)
      redirect_to action: "show", controller: "home"
		end

	end
end
