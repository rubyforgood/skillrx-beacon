FactoryBot.define do
  factory :topic do
    association :content_provider
    year { 2024 }
    month { "January" }
    sequence(:title) { |n| "Topic #{n}" }
    volume { "1" }
    issue { "1" }
    view_count { 0 }
    sequence(:topic_external_id) { |n| "ext_#{n}" }
  end
end
