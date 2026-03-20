class ChatMessage < ApplicationRecord
  belongs_to :onboarding_application

  ROLES = %w[user assistant].freeze

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :content, presence: true, length: { maximum: 10_000 }

  scope :recent, -> { order(created_at: :asc).last(50) }
end
