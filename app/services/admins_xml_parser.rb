class AdminsXmlParser < XmlParser
  def parse
    document.xpath("//ADMIN_DETAIL").map do |node|
      {
        first_name: node.at_xpath("USER_FNAME")&.text&.strip,
        last_name: node.at_xpath("USER_LNAME")&.text&.strip,
        login_id: node.at_xpath("USER_ID")&.text&.strip&.downcase,
        legacy_password_hash: node.at_xpath("PASSWORD")&.text&.strip
      }
    end
  end
end
