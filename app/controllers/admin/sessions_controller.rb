class Admin::SessionsController < ApplicationController
  layout "admin"

  def new
    redirect_to admin_root_path if admin_signed_in?
  end

  def create
    admin = Admin.find_by(login_id: params[:login_id]&.downcase&.strip)

    if admin&.authenticate(params[:password])
      sign_in_admin(admin)
      log_admin_activity("login")
      redirect_to admin_root_path, notice: "Welcome back, #{admin.first_name}!"
    else
      flash.now[:alert] = "Invalid login ID or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out_admin
    redirect_to admin_login_path, notice: "You have been signed out."
  end
end
