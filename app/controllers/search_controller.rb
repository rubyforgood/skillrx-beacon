class SearchController < ApplicationController
  def index
    @query = params[:q]
    @search_service = SearchService.new(@query)
    @topics = @search_service.search if @query.present?

    log_search if @query.present? && user_signed_in?
  end

  def autocomplete
    search_service = SearchService.new(params[:q])
    suggestions = search_service.autocomplete_suggestions

    render json: suggestions
  end

  def results
    @query = params[:q]
    @search_service = SearchService.new(@query)
    @topics = @search_service.search

    log_search if user_signed_in?

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def log_search
    log_user_activity(
      "search",
      search_term: @query,
      search_found: @search_service.found?
    )
  end
end
