class SearchService
  attr_reader :query

  def initialize(query)
    @query = query&.strip
  end

  def search
    return Topic.none if query.blank?

    Topic.includes(:content_provider, :authors, :tags, :topic_files)
         .left_joins(:tags, :authors)
         .where(search_conditions)
         .distinct
         .order(view_count: :desc)
  end

  def autocomplete_suggestions(limit: 10)
    return [] if query.blank? || query.length < 2

    suggestions = []

    # Tag suggestions
    suggestions += Tag.where("name LIKE ?", "#{query}%")
                      .limit(5)
                      .pluck(:name)
                      .map { |name| { type: "tag", value: name } }

    # Title suggestions
    suggestions += Topic.where("title LIKE ?", "%#{query}%")
                        .limit(5)
                        .pluck(:title)
                        .map { |title| { type: "topic", value: title } }

    # Author suggestions
    suggestions += Author.where("name LIKE ?", "%#{query}%")
                         .limit(5)
                         .pluck(:name)
                         .map { |name| { type: "author", value: name } }

    suggestions.uniq { |s| s[:value].downcase }.first(limit)
  end

  def found?
    search.exists?
  end

  private

  def search_conditions
    sanitized_query = "%#{query}%"

    Topic.arel_table[:title].matches(sanitized_query)
         .or(Tag.arel_table[:name].matches(sanitized_query))
         .or(Author.arel_table[:name].matches(sanitized_query))
  end
end
