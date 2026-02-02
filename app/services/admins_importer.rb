class AdminsImporter
  DEFAULT_PASSWORD = "changeme123"

  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def import
    parsed_admins = AdminsXmlParser.new(file_path).parse
    results = { created: 0, updated: 0, errors: [], password_reset_needed: [] }

    parsed_admins.each do |admin_data|
      import_admin(admin_data, results)
    end

    results
  end

  private

  def import_admin(admin_data, results)
    admin = Admin.find_or_initialize_by(login_id: admin_data[:login_id])
    is_new = admin.new_record?

    admin.assign_attributes(
      first_name: admin_data[:first_name],
      last_name: admin_data[:last_name]
    )

    if is_new
      admin.password = DEFAULT_PASSWORD
      admin.password_confirmation = DEFAULT_PASSWORD
      results[:password_reset_needed] << admin_data[:login_id]
    end

    if admin.save
      is_new ? results[:created] += 1 : results[:updated] += 1
    else
      results[:errors] << "Admin #{admin_data[:login_id]}: #{admin.errors.full_messages.join(', ')}"
    end
  end
end
