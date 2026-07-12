class ContentImporter
  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def import
    parsed_content = ContentXmlParser.new(file_path).parse
    results = {
      providers: { created: 0 },
      topics: { created: 0, updated: 0 },
      files: { created: 0 },
      authors: { created: 0 },
      tags: { created: 0 },
      errors: [],
    }

    parsed_content.each do |provider_data|
      import_provider(provider_data, results)
    end

    results
  end

  def topic_id_map
    Topic.pluck(:topic_external_id, :id).to_h
  end

  private

  def import_provider(provider_data, results)
    provider = ContentProvider.find_or_create_by!(name: provider_data[:name])
    results[:providers][:created] += 1 if provider.previously_new_record?

    provider_data[:topics].each do |topic_data|
      import_topic(provider, topic_data, results)
    end
  end

  def import_topic(provider, topic_data, results)
    topic = Topic.find_or_initialize_by(topic_external_id: topic_data[:topic_external_id])
    is_new = topic.new_record?

    topic.assign_attributes(
      content_provider: provider,
      title: topic_data[:title],
      year: topic_data[:year],
      month: topic_data[:month],
      volume: topic_data[:volume],
      issue: topic_data[:issue],
      view_count: topic_data[:view_count]
    )

    if topic.save
      is_new ? results[:topics][:created] += 1 : results[:topics][:updated] += 1
      import_files(topic, topic_data[:files], results)
      import_authors(topic, topic_data[:authors], results)
      import_tags(topic, topic_data[:tags], results)
    else
      results[:errors] << "Topic #{topic_data[:topic_external_id]}: #{topic.errors.full_messages.join(', ')}"
    end
  end

  def import_files(topic, files_data, results)
    files_data.each do |file_data|
      next if file_data[:file_type].nil?

      topic_file = TopicFile.find_or_initialize_by(
        topic: topic,
        filename: file_data[:filename]
      )

      if topic_file.new_record?
        topic_file.assign_attributes(
          file_size: file_data[:file_size],
          file_type: file_data[:file_type]
        )

        if topic_file.save
          results[:files][:created] += 1
        else
          results[:errors] << "File #{file_data[:filename]}: #{topic_file.errors.full_messages.join(', ')}"
        end
      end
    end
  end

  def import_authors(topic, author_names, results)
    author_names.each do |name|
      author = Author.find_or_create_by!(name: name)
      results[:authors][:created] += 1 if author.previously_new_record?

      TopicAuthor.find_or_create_by!(topic: topic, author: author)
    end
  end

  def import_tags(topic, tag_names, results)
    tag_names.each do |name|
      tag = Tag.find_or_create_by!(name: name)
      results[:tags][:created] += 1 if tag.previously_new_record?

      TopicTag.find_or_create_by!(topic: topic, tag: tag)
    end
  end
end
