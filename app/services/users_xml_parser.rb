class UsersXmlParser < XmlParser
  def parse
    document.xpath("//USER_DETAIL").map do |node|
      {
        first_name: node.at_xpath("USER_FNAME")&.text&.strip,
        last_name: node.at_xpath("USER_LNAME")&.text&.strip,
        login_id: node.at_xpath("USER_ID")&.text&.strip&.downcase,
        login_count: node.at_xpath("LOGIN_COUNTER")&.text&.to_i || 0,
        favorites: parse_favorites(node.at_xpath("FAVOURITE")&.text)
      }
    end
  end

  private

  def parse_favorites(favorites_text)
    return [] if favorites_text.blank?

    favorites_text.split(",").map(&:strip).reject(&:blank?)
  end
end
