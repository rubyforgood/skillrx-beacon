module BrowserDetection
  extend ActiveSupport::Concern

  included do
    before_action :reject_ie_browser
    helper_method :mobile_device?
  end

  def ie_browser?
    request.user_agent&.match?(/MSIE|Trident/)
  end

  def mobile_device?
    request.user_agent&.match?(/Mobile|Android|iPhone|iPad/)
  end

  private

  def reject_ie_browser
    redirect_to unsupported_browser_path if ie_browser?
  end
end
