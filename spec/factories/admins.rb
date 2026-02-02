FactoryBot.define do
  factory :admin do
    sequence(:first_name) { |n| "Admin#{n}" }
    sequence(:last_name) { |n| "User#{n}" }
    sequence(:login_id) { |n| "admin#{n}" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
