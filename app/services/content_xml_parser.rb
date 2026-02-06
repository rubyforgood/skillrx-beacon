class ContentXmlParser < XmlParser
  def parse
    providers = []

    document.xpath("//Content_Provider").each do |provider_node|
      provider_name = provider_node["name"]
      topics = parse_topics(provider_node)
      providers << { name: provider_name, topics: topics }
    end

    providers
  end

  private

  def parse_topics(provider_node)
    topics = []

    provider_node.xpath(".//title").each do |title_node|
      year_node = title_node.ancestors("topic_year").first
      month_node = title_node.ancestors("topic_month").first

      topics << {
        title: title_node["name"],
        year: year_node&.attr("year")&.to_i,
        month: parse_month(month_node&.attr("month")),
        topic_external_id: title_node.at_xpath("topic_id")&.text&.strip,
        view_count: title_node.at_xpath("counter")&.text&.to_i || 0,
        volume: title_node.at_xpath("topic_volume")&.text&.strip,
        issue: title_node.at_xpath("topic_issue")&.text&.strip,
        files: parse_files(title_node),
        authors: parse_authors(title_node),
        tags: parse_tags(title_node),
      }
    end

    topics
  end

  def parse_month(month_string)
    return nil if month_string.blank?

    month_string.split("_").last
  end

  def parse_files(title_node)
    files = []
    files_node = title_node.at_xpath("topic_files")
    return files unless files_node

    files_node.children.each do |file_node|
      next unless file_node.element? && file_node.name.start_with?("file_name_")

      filename = file_node.text&.strip
      next if filename.blank?

      files << {
        filename: filename,
        file_size: file_node["file_size"]&.to_i,
        file_type: determine_file_type(filename),
      }
    end

    files
  end

  def parse_authors(title_node)
    authors = []
    authors_node = title_node.at_xpath("topic_authors")
    return authors unless authors_node

    authors_node.children.each do |author_node|
      next unless author_node.element? && author_node.name.start_with?("topic_author_")

      name = author_node.text&.strip
      authors << name unless name.blank?
    end

    authors
  end

  def parse_tags(title_node)
    tags_text = title_node.at_xpath("topic_tags")&.text&.strip
    return [] if tags_text.blank? || tags_text == "N/A"

    tags_text.split(",").map(&:strip).reject(&:blank?)
  end

  def determine_file_type(filename)
    extension = File.extname(filename).downcase.delete(".")
    %w[pdf mp3].include?(extension) ? extension : nil
  end
end
