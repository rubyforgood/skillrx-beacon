class AdminActivityLog < ApplicationRecord
  belongs_to :admin

  ACTION_TYPES = %w[login upload delete].freeze

  validates :action_type, presence: true, inclusion: { in: ACTION_TYPES }

  scope :logins, -> { where(action_type: "login") }
  scope :uploads, -> { where(action_type: "upload") }
  scope :deletes, -> { where(action_type: "delete") }
end
