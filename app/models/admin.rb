class Admin < ApplicationRecord
  has_secure_password

  has_many :local_files, dependent: :destroy
  has_many :activity_logs, class_name: "AdminActivityLog", dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :login_id, presence: true, uniqueness: true
end
