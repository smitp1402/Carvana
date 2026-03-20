class OnboardingApplication < ApplicationRecord
  belongs_to :user
  belongs_to :vehicle
  has_many :document_uploads, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  STEPS = {
    1 => "pre_qualification",
    2 => "financing",
    3 => "documents",
    4 => "review",
    5 => "complete"
  }.freeze

  STATUSES = %w[in_progress submitted approved rejected].freeze

  serialize :application_data, coder: JSON

  before_create :set_defaults

  def current_step_name
    STEPS[current_step] || "pre_qualification"
  end

  def progress_percentage
    ((current_step.to_f / STEPS.length) * 100).round
  end

  def advance_step!
    return if current_step >= STEPS.length
    update!(current_step: current_step + 1)
  end

  def complete?
    current_step >= STEPS.length
  end

  def data
    application_data || {}
  end

  def update_data(new_data)
    update!(application_data: data.merge(new_data))
  end

  private

  def set_defaults
    self.current_step ||= 1
    self.status ||= "in_progress"
    self.application_data ||= {}
  end
end
