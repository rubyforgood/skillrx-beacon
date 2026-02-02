class UsersImporter
  attr_reader :file_path, :topic_id_map

  def initialize(file_path, topic_id_map: {})
    @file_path = file_path
    @topic_id_map = topic_id_map
  end

  def import
    parsed_users = UsersXmlParser.new(file_path).parse
    results = { created: 0, updated: 0, errors: [] }

    parsed_users.each do |user_data|
      import_user(user_data, results)
    end

    results
  end

  private

  def import_user(user_data, results)
    user = User.find_or_initialize_by(login_id: user_data[:login_id])
    is_new = user.new_record?

    user.assign_attributes(
      first_name: user_data[:first_name],
      last_name: user_data[:last_name],
      login_count: user_data[:login_count]
    )

    if user.save
      import_favorites(user, user_data[:favorites])
      is_new ? results[:created] += 1 : results[:updated] += 1
    else
      results[:errors] << "User #{user_data[:login_id]}: #{user.errors.full_messages.join(', ')}"
    end
  end

  def import_favorites(user, favorite_topic_ids)
    return if favorite_topic_ids.blank?

    favorite_topic_ids.each do |external_id|
      topic_id = topic_id_map[external_id]
      next unless topic_id

      Favorite.find_or_create_by(user: user, topic_id: topic_id)
    end
  end
end
