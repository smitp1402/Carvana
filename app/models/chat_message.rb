class ChatMessage < ApplicationRecord
  belongs_to :onboarding_application

  ROLES = %w[user assistant].freeze

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :content, presence: true

  scope :recent, -> { order(created_at: :asc).last(50) }
end
