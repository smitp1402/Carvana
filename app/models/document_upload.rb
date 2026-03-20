class DocumentUpload < ApplicationRecord
  belongs_to :onboarding_application
  has_one_attached :image

  DOCUMENT_TYPES = %w[license pay_stub insurance].freeze
  STATUSES = %w[pending processing verified needs_review failed].freeze

  validates :document_type, presence: true, inclusion: { in: DOCUMENT_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :set_defaults, on: :create

  def extracted_fields
    return {} unless extracted_data.present?

    parsed = JSON.parse(extracted_data)
    parsed["mapped"] || {}
  rescue JSON::ParserError
    {}
  end

  def confidence_score
    return 0.0 unless extracted_data.present?

    parsed = JSON.parse(extracted_data)
    parsed["confidence"] || 0.0
  rescue JSON::ParserError
    0.0
  end

  def verified?
    status == "verified"
  end

  def type_label
    DocumentValidator::DOCUMENT_TYPE_LABELS.fetch(document_type, document_type.humanize)
  end

  private

  def set_defaults
    self.status ||= "pending"
  end
end
