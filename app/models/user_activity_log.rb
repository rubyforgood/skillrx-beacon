class UserActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :topic, optional: true

  ACTION_TYPES = %w[login view search favorite unfavorite view_local_file].freeze

  validates :action_type, presence: true, inclusion: { in: ACTION_TYPES }

  scope :logins, -> { where(action_type: "login") }
  scope :views, -> { where(action_type: "view") }
  scope :searches, -> { where(action_type: "search") }
  scope :favorites, -> { where(action_type: "favorite") }
  scope :unfavorites, -> { where(action_type: "unfavorite") }
end
