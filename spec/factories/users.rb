FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "User#{n}" }
    sequence(:last_name) { |n| "Test#{n}" }
    login_id { nil }
    login_count { 0 }
  end
end
