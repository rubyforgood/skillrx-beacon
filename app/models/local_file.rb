class LocalFile < ApplicationRecord
  belongs_to :admin

  has_one_attached :file

  validates :folder_path, presence: true
end
