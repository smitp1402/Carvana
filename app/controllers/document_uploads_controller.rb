class DocumentUploadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_application

  def create
    document_type = params[:document_type].to_s
    file = params[:file]

    begin
      validator = DocumentValidator.new(file, document_type)
      validator.validate!
    rescue DocumentValidator::ValidationError => e
      render json: { error: e.message, code: e.code }, status: :unprocessable_entity
      return
    end

    doc = @application.document_uploads.create!(
      document_type: document_type,
      status: "processing",
      filename: file.original_filename
    )
    doc.image.attach(file)

    service = OcrService.new(doc)
    result = service.extract

    auto_fill_application(document_type, result[:fields])

    render json: {
      id: doc.id,
      document_type: document_type,
      status: result[:status],
      confidence: result[:confidence],
      fields: result[:fields]
    }
  rescue OcrService::ExtractionError => e
    Rails.logger.error("OCR error: #{e.message}")
    render json: {
      error: "We couldn't read this document clearly. Please retake the photo with better lighting.",
      code: :extraction_failed
    }, status: :unprocessable_entity
  end

  def scan
    create
  end

  private

  def set_application
    @application = current_user.onboarding_applications.find(params[:application_id])
  end

  def auto_fill_application(document_type, fields)
    return if fields.empty?

    data_updates = case document_type
    when "license"
      {
        "first_name" => fields["first_name"],
        "last_name" => fields["last_name"],
        "date_of_birth" => fields["date_of_birth"],
        "address" => fields["address"],
        "license_number" => fields["license_number"]
      }.compact
    when "pay_stub"
      {
        "employer_name" => fields["employer_name"],
        "gross_income" => fields["gross_income"],
        "pay_period" => fields["pay_period"]
      }.compact
    when "insurance"
      {
        "policy_number" => fields["policy_number"],
        "insurance_carrier" => fields["carrier"],
        "coverage_start" => fields["coverage_start"],
        "coverage_end" => fields["coverage_end"]
      }.compact
    else
      {}
    end

    @application.update_data(data_updates) if data_updates.any?

    verification_flag = case document_type
    when "license" then "license_verified"
    when "pay_stub" then "income_verified"
    when "insurance" then "insurance_verified"
    end

    @application.update_data(verification_flag => true) if verification_flag
  end
end
