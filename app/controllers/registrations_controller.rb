class RegistrationsController < ApplicationController
  def new
    redirect_to root_path if user_signed_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      sign_in(@user)
      log_user_activity("login")
      redirect_to root_path, notice: "Welcome, #{@user.first_name}! Your login ID is: #{@user.login_id}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name)
  end
end
