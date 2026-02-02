module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_admin, :admin_signed_in?
  end

  def current_admin
    return @current_admin if defined?(@current_admin)

    @current_admin = session[:admin_id] && Admin.find_by(id: session[:admin_id])
  end

  def admin_signed_in?
    current_admin.present?
  end

  def authenticate_admin!
    unless admin_signed_in?
      redirect_to admin_login_path, alert: "Please sign in to access admin area."
    end
  end

  def sign_in_admin(admin)
    session[:admin_id] = admin.id
    @current_admin = admin
  end

  def sign_out_admin
    session.delete(:admin_id)
    @current_admin = nil
  end
end
