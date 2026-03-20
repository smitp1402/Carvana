class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :onboarding_applications, dependent: :destroy

  EXPERIENCE_LEVELS = { first_time: 0, experienced: 1 }.freeze
  enum :experience_level, EXPERIENCE_LEVELS, default: :first_time

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def first_time_buyer?
    experience_level == "first_time"
  end
end
