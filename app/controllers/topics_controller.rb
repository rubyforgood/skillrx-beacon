class TopicsController < ApplicationController
  before_action :authenticate_user!, only: [ :favorites, :toggle_favorite ]
  before_action :set_topic, only: [ :show, :toggle_favorite ]

  def index
    @years = Topic.distinct.pluck(:year).compact.sort.reverse
    @content_providers = ContentProvider.all
  end

  def show
    @topic.increment!(:view_count)
    log_user_activity("view", topic: @topic) if user_signed_in?
    @is_favorite = user_signed_in? && current_user.favorites.exists?(topic: @topic)
  end

  def by_year
    @year = params[:year].to_i
    @month = params[:month]

    @topics = Topic.includes(:content_provider, :authors, :topic_files)
                   .by_year(@year)

    @topics = @topics.by_month(@month) if @month.present?
    @topics = @topics.order(month: :asc, title: :asc)

    @months = Topic.by_year(@year).distinct.pluck(:month).compact.sort_by do |m|
      Date::MONTHNAMES.index(m) || 0
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new_uploads
    @topics = Topic.includes(:content_provider, :authors, :topic_files)
                   .new_uploads
                   .order(created_at: :desc)
  end

  def top_topics
    @topics = Topic.includes(:content_provider, :authors, :topic_files)
                   .top_topics
  end

  def favorites
    @topics = Topic.includes(:content_provider, :authors, :topic_files)
                   .favorites_for(current_user)
                   .order(created_at: :desc)
  end

  def toggle_favorite
    favorite = current_user.favorites.find_by(topic: @topic)

    if favorite
      favorite.destroy
      @is_favorite = false
      log_user_activity("unfavorite", topic: @topic)
    else
      current_user.favorites.create(topic: @topic)
      @is_favorite = true
      log_user_activity("favorite", topic: @topic)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @topic }
    end
  end

  private

  def set_topic
    @topic = Topic.includes(:content_provider, :authors, :tags, :topic_files).find(params[:id])
  end
end
