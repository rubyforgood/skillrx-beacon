FactoryBot.define do
  factory :topic_file do
    association :topic
    sequence(:filename) { |n| "file_#{n}.mp3" }
    file_size { 1024000 }
    file_type { "mp3" }
  end
end
