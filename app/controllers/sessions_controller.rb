class SessionsController < ApplicationController
  def new
    redirect_to root_path if user_signed_in?
  end

  def create
    user = User.find_by(login_id: params[:login_id]&.downcase&.strip)

    if user
      user.increment!(:login_count)
      sign_in(user)
      log_user_activity("login")
      redirect_to stored_location_or(root_path), notice: "Welcome back, #{user.first_name}!"
    else
      flash.now[:alert] = "User not found. Please check your login ID or sign up."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out_user
    redirect_to root_path, notice: "You have been signed out."
  end
end
