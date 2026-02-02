module ActivityLogging
  extend ActiveSupport::Concern

  private

  def log_user_activity(action_type, topic: nil, file_type: nil, search_term: nil, search_found: nil)
    return unless current_user

    UserActivityLog.create(
      user: current_user,
      action_type: action_type,
      topic: topic,
      file_type: file_type,
      search_term: search_term,
      search_found: search_found,
      os: detect_os,
      browser: detect_browser,
      ip_address: request.remote_ip
    )
  end

  def log_admin_activity(action_type, details: nil)
    return unless current_admin

    AdminActivityLog.create(
      admin: current_admin,
      action_type: action_type,
      details: details,
      os: detect_os,
      browser: detect_browser,
      ip_address: request.remote_ip
    )
  end

  def detect_os
    user_agent = request.user_agent.to_s
    case user_agent
    when /Windows/i then "Windows"
    when /Macintosh|Mac OS/i then "macOS"
    when /Linux/i then "Linux"
    when /Android/i then "Android"
    when /iPhone|iPad/i then "iOS"
    else "Unknown"
    end
  end

  def detect_browser
    user_agent = request.user_agent.to_s
    case user_agent
    when /Chrome/i then "Chrome"
    when /Firefox/i then "Firefox"
    when /Safari/i then "Safari"
    when /Edge/i then "Edge"
    when /MSIE|Trident/i then "Internet Explorer"
    else "Unknown"
    end
  end
end
