FactoryBot.define do
  factory :admin_activity_log do
    admin { nil }
    action_type { "MyString" }
    details { "MyText" }
    os { "MyString" }
    browser { "MyString" }
    ip_address { "MyString" }
  end
end
