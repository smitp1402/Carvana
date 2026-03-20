class DocumentValidator
  class ValidationError < StandardError
    attr_reader :code

    def initialize(message, code:)
      @code = code
      super(message)
    end
  end

  ALLOWED_MIME_TYPES = %w[image/jpeg image/png image/webp image/heic application/pdf].freeze
  MIN_FILE_SIZE = 50.kilobytes
  MAX_FILE_SIZE = 10.megabytes

  DOCUMENT_TYPE_LABELS = {
    "license" => "Driver's License",
    "pay_stub" => "Pay Stub",
    "insurance" => "Insurance Card"
  }.freeze

  def initialize(file, document_type)
    @file = file
    @document_type = document_type
  end

  def validate!
    validate_presence!
    validate_document_type!
    validate_mime_type!
    validate_file_size!
  end

  private

  def validate_presence!
    return if @file.present?

    raise ValidationError.new(
      "No file uploaded. Please select or capture a document image.",
      code: :no_file
    )
  end

  def validate_document_type!
    return if OcrService::DOCUMENT_TYPES.include?(@document_type)

    raise ValidationError.new(
      "Invalid document type. Expected one of: #{OcrService::DOCUMENT_TYPES.join(', ')}.",
      code: :invalid_type
    )
  end

  def validate_mime_type!
    content_type = @file.content_type
    return if ALLOWED_MIME_TYPES.include?(content_type)

    raise ValidationError.new(
      "Unsupported file format (#{content_type}). Please upload a JPEG, PNG, or PDF.",
      code: :invalid_format
    )
  end

  def validate_file_size!
    size = @file.size

    if size < MIN_FILE_SIZE
      raise ValidationError.new(
        "File is too small (#{(size / 1024.0).round(1)} KB). The image may be too low quality. Please retake the photo.",
        code: :too_small
      )
    end

    if size > MAX_FILE_SIZE
      raise ValidationError.new(
        "File is too large (#{(size / 1.megabyte).round(1)} MB). Maximum size is #{MAX_FILE_SIZE / 1.megabyte} MB.",
        code: :too_large
      )
    end
  end
end
