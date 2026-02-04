class Author < ApplicationRecord
  has_many :topic_authors, dependent: :destroy
  has_many :topics, through: :topic_authors

  validates :name, presence: true
end
