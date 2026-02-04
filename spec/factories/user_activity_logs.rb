FactoryBot.define do
  factory :user_activity_log do
    user { nil }
    action_type { "MyString" }
    topic { nil }
    file_type { "MyString" }
    search_term { "MyString" }
    search_found { false }
    os { "MyString" }
    browser { "MyString" }
    ip_address { "MyString" }
  end
end
