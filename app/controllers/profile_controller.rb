class ProfileController < ApplicationController
  include ApplicationHelper
  skip_before_action :verify_user, only: [:new, :update]
  skip_before_action :verify_user
  skip_before_action :verify_authenticity_token

  def new
    @user = User.new
    @ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
    @classes = Group.where(group_type: "peer_class").order(:name).pluck(:name)
    @user_name = session[:user_name]
  end

  def show
    verify_oath_user()
    session_email = session[:user_email]

    @ministry_names = Group.where(group_type: "ministry").order(:name).pluck(:name)
    @classes = Group.where(group_type: "peer_class").order(:name).pluck(:name)
    
    @user = User.where(email: session_email).take
    if @user != nil
      #redirect_to root_path
      @user_ministry = @user.ministry.name
      @user_peer_class = @user.peer_class.name
      @user_name = @user.name
      @user_email = @user.email
      @user_gender = if @user.gender then "Male" else "Female" end
      session[:uid] = @user.id
    else
      @user = User.new
    end
  end

  def update 
    session_email = session[:user_email]
    @user = User.where(email: session_email).take

    input = params[:user]
    input_name = input[:name]
    input_ministry = Group.where(group_type: "ministry", name: input[:ministry]).take
    input_peer_class = Group.where(group_type: "peer_class", name: input[:peer_class]).take
    input_gender = if input[:gender] == "Male" then true else false end

    if @user != nil
      @user.update!(
        name: input_name,
        email: session_email,
        gender: input_gender,
        ministry: input_ministry,
        peer_class: input_peer_class
      )
      redirect_to action: "show", controller: "profile"
    else
      year = DateTime.now.year
      new_lifetime = Count.create!(year: 0, count: 0)
      current_annual = Count.create!(year: Time.now.year, count: 0)
      @user = User.create(
        name: input_name,
        email: session_email,
        gender: input_gender,
        peer_class: input_peer_class,
        ministry: input_ministry,
        lifetime_count: new_lifetime,
      )
      @user.annual_counts << current_annual.id
      @user.save
      session[:user_id] = @user.id

      new_shadowings = bible_books.map { |book_name|
        {
          user: @user,
          book: book_name,
          shadowing: []
        }
      }
      UserShadowing.create!(new_shadowings)
      redirect_to action: "show", controller: "dashboard"
    end
  end

  def create
    user =  params[:user]
    peer_class = Group.where(group_type: "peer_class", name: user[:peer_class]).take
    ministry = Group.where(group_type: "ministry", name: user[:ministry]).take
    new_lifetime = Count.create(year: 0, count: 0)
    user_gender = if user[:gender] == "Male" then true else false end
    @user = User.create!(
      name: user[:name],
      email: session[:email],
      gender: user_gender,
      peer_class: peer_class,
      ministry: ministry,
      lifetime_count: new_lifetime
    )
    session[:uid] = @user.id

  end
end
