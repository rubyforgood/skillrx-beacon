class TopicFile < ApplicationRecord
  belongs_to :topic

  has_one_attached :file

  validates :filename, presence: true
  validates :file_type, presence: true, inclusion: { in: %w[pdf mp3] }

  scope :pdfs, -> { where(file_type: "pdf") }
  scope :mp3s, -> { where(file_type: "mp3") }
end
