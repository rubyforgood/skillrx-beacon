class Topic < ApplicationRecord
  belongs_to :content_provider

  has_many :topic_files, dependent: :destroy
  has_many :topic_authors, dependent: :destroy
  has_many :authors, through: :topic_authors
  has_many :topic_tags, dependent: :destroy
  has_many :tags, through: :topic_tags
  has_many :favorites, dependent: :destroy
  has_many :favorited_by_users, through: :favorites, source: :user

  validates :title, presence: true
  validates :year, presence: true
  validates :topic_external_id, uniqueness: true, allow_nil: true

  scope :by_year, ->(year) { where(year: year) }
  scope :by_month, ->(month) { where(month: month) }
  scope :new_uploads, -> { where("created_at > ?", 30.days.ago) }
  scope :top_topics, -> { order(view_count: :desc).limit(50) }
  scope :favorites_for, ->(user) { joins(:favorites).where(favorites: { user: user }) }
end
