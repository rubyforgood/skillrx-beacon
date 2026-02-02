class TopicAuthor < ApplicationRecord
  belongs_to :topic
  belongs_to :author
end
