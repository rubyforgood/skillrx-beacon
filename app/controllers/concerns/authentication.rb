module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = session[:user_id] && User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    unless user_signed_in?
      store_location
      redirect_to login_path, alert: "Please sign in to continue."
    end
  end

  def sign_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def sign_out_user
    session.delete(:user_id)
    @current_user = nil
  end

  private

  def store_location
    session[:return_to] = request.fullpath if request.get? || request.head?
  end

  def stored_location_or(default)
    session.delete(:return_to) || default
  end
end
