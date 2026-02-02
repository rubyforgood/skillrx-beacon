class StatsService
  def initialize(days: 30)
    @days = days
    @start_date = days.days.ago.beginning_of_day
  end

  # Overview statistics
  def overview
    {
      total_users: User.count,
      total_topics: Topic.count,
      total_files: TopicFile.count,
      total_authors: Author.count,
      total_tags: Tag.count,
      total_favorites: Favorite.count,
      total_local_files: LocalFile.count
    }
  end

  # Activity summary for the period
  def activity_summary
    base_query = UserActivityLog.where("created_at >= ?", @start_date)

    {
      total_activities: base_query.count,
      logins: base_query.logins.count,
      views: base_query.views.count,
      searches: base_query.searches.count,
      favorites: base_query.favorites.count,
      unfavorites: base_query.unfavorites.count,
      unique_users: base_query.distinct.count(:user_id)
    }
  end

  # Top users by activity count
  def top_users(limit: 10)
    User.joins(:user_activity_logs)
        .where("user_activity_logs.created_at >= ?", @start_date)
        .group("users.id")
        .select("users.*, COUNT(user_activity_logs.id) as activity_count")
        .order("activity_count DESC")
        .limit(limit)
  end

  # Most viewed topics
  def hot_topics(limit: 10)
    Topic.includes(:content_provider, :authors)
         .order(view_count: :desc)
         .limit(limit)
  end

  # Recently viewed topics (in the period)
  def recently_viewed_topics(limit: 10)
    Topic.joins(:user_activity_logs)
         .where("user_activity_logs.action_type = ?", "view")
         .where("user_activity_logs.created_at >= ?", @start_date)
         .group("topics.id")
         .select("topics.*, COUNT(user_activity_logs.id) as recent_views")
         .order("recent_views DESC")
         .limit(limit)
  end

  # Most favorited topics
  def most_favorited_topics(limit: 10)
    Topic.joins(:favorites)
         .group("topics.id")
         .select("topics.*, COUNT(favorites.id) as favorites_count")
         .order("favorites_count DESC")
         .limit(limit)
  end

  # Popular search terms
  def popular_searches(limit: 20)
    UserActivityLog.searches
                   .where("created_at >= ?", @start_date)
                   .where.not(search_term: [ nil, "" ])
                   .group(:search_term)
                   .order("count_all DESC")
                   .limit(limit)
                   .count
  end

  # Failed searches (no results found)
  def failed_searches(limit: 10)
    UserActivityLog.searches
                   .where("created_at >= ?", @start_date)
                   .where(search_found: false)
                   .where.not(search_term: [ nil, "" ])
                   .group(:search_term)
                   .order("count_all DESC")
                   .limit(limit)
                   .count
  end

  # Logins per day for chart
  def logins_per_day
    UserActivityLog.logins
                   .where("created_at >= ?", @start_date)
                   .group_by_day(:created_at)
                   .count
  end

  # Activity per day for chart
  def activity_per_day
    UserActivityLog.where("created_at >= ?", @start_date)
                   .group_by_day(:created_at)
                   .count
  end

  # Recent activity log entries
  def recent_activities(limit: 50)
    UserActivityLog.includes(:user, :topic)
                   .order(created_at: :desc)
                   .limit(limit)
  end

  # Admin activity log entries
  def admin_activities(limit: 50)
    AdminActivityLog.includes(:admin)
                    .order(created_at: :desc)
                    .limit(limit)
  end

  # Content by year
  def content_by_year
    Topic.group(:year)
         .order(year: :desc)
         .count
  end

  # Content by provider
  def content_by_provider
    Topic.joins(:content_provider)
         .group("content_providers.name")
         .count
  end

  private

  # Helper to group by day (simple implementation without groupdate gem)
  def group_by_day(relation, column)
    relation.group("DATE(#{column})")
  end
end

# Extend ActiveRecord to add group_by_day if groupdate gem is not available
module GroupByDayExtension
  def group_by_day(column)
    group("DATE(#{column})")
  end
end

ActiveRecord::Relation.include(GroupByDayExtension)
