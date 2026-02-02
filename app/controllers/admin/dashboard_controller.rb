class Admin::DashboardController < Admin::BaseController
  def index
    @period = (params[:period] || 30).to_i
    @stats_service = StatsService.new(days: @period)

    @overview = @stats_service.overview
    @activity_summary = @stats_service.activity_summary
    @top_users = @stats_service.top_users(limit: 10)
    @hot_topics = @stats_service.hot_topics(limit: 10)
    @popular_searches = @stats_service.popular_searches(limit: 15)
    @failed_searches = @stats_service.failed_searches(limit: 10)
    @logins_per_day = @stats_service.logins_per_day
    @recent_activities = @stats_service.recent_activities(limit: 20)
    @content_by_provider = @stats_service.content_by_provider
  end

  def activity_log
    @activities = UserActivityLog.includes(:user, :topic)
                                 .order(created_at: :desc)
                                 .limit(100)
  end

  def admin_log
    @activities = AdminActivityLog.includes(:admin)
                                  .order(created_at: :desc)
                                  .limit(100)
  end
end
