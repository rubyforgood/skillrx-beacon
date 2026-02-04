namespace :data do
  desc "Import users from legacy XML file"
  task import_users: :environment do |_task, args|
    file_path = args.extras.first || default_xml_path("users.xml")

    puts "Importing users from #{file_path}..."

    topic_id_map = Topic.pluck(:topic_external_id, :id).to_h
    results = UsersImporter.new(file_path, topic_id_map: topic_id_map).import

    puts "Users import complete:"
    puts "  Created: #{results[:created]}"
    puts "  Updated: #{results[:updated]}"
    puts "  Errors: #{results[:errors].count}"
    results[:errors].each { |error| puts "    - #{error}" }
  end

  desc "Import admins from legacy XML file"
  task import_admins: :environment do |_task, args|
    file_path = args.extras.first || default_xml_path("admin.xml")

    puts "Importing admins from #{file_path}..."

    results = AdminsImporter.new(file_path).import

    puts "Admins import complete:"
    puts "  Created: #{results[:created]}"
    puts "  Updated: #{results[:updated]}"
    puts "  Errors: #{results[:errors].count}"
    results[:errors].each { |error| puts "    - #{error}" }

    if results[:password_reset_needed].any?
      puts "\nPassword reset needed for:"
      results[:password_reset_needed].each { |login| puts "    - #{login}" }
      puts "\nDefault password: 'changeme123'"
    end
  end

  desc "Import content (topics, files, authors, tags) from legacy XML file"
  task import_content: :environment do |_task, args|
    file_path = args.extras.first || default_xml_path("Server_XML.xml")

    puts "Importing content from #{file_path}..."

    results = ContentImporter.new(file_path).import

    puts "Content import complete:"
    puts "  Providers created: #{results[:providers][:created]}"
    puts "  Topics created: #{results[:topics][:created]}"
    puts "  Topics updated: #{results[:topics][:updated]}"
    puts "  Files created: #{results[:files][:created]}"
    puts "  Authors created: #{results[:authors][:created]}"
    puts "  Tags created: #{results[:tags][:created]}"
    puts "  Errors: #{results[:errors].count}"
    results[:errors].each { |error| puts "    - #{error}" }
  end

  desc "Import all data from legacy XML files"
  task import_all: :environment do
    Rake::Task["data:import_content"].invoke
    Rake::Task["data:import_users"].invoke
    Rake::Task["data:import_admins"].invoke
  end

  def default_xml_path(filename)
    legacy_path = Rails.root.join("..", "CMES-Pi-BOOM_English_Updated", "assets", "XML", filename)
    return legacy_path.to_s if File.exist?(legacy_path)

    Rails.root.join("assets", "XML", filename).to_s
  end
end
