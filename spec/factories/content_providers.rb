FactoryBot.define do
  factory :content_provider do
    sequence(:name) { |n| "Provider #{n}" }
  end
end
