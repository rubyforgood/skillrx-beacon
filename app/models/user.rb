class User < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :favorite_topics, through: :favorites, source: :topic
  has_many :activity_logs, class_name: "UserActivityLog", dependent: :destroy
  has_many :user_activity_logs, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :login_id, presence: true, uniqueness: true

  before_validation :generate_login_id, on: :create

  private

  def generate_login_id
    return if login_id.present?
    return unless first_name.present? && last_name.present?

    base_login = "#{first_name}.#{last_name}".downcase.gsub(/\s+/, "")
    self.login_id = unique_login_id(base_login)
  end

  def unique_login_id(base)
    candidate = base
    counter = 1

    while User.exists?(login_id: candidate)
      candidate = "#{base}#{counter}"
      counter += 1
    end

    candidate
  end
end
