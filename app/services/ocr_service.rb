class OcrService
  class ExtractionError < StandardError; end

  DOCUMENT_TYPES = %w[license pay_stub insurance].freeze

  FIELD_MAPPINGS = {
    "license" => {
      "first_name" => ["FIRST NAME", "FN", "GIVEN NAME"],
      "last_name" => ["LAST NAME", "LN", "SURNAME", "FAMILY NAME"],
      "date_of_birth" => ["DOB", "DATE OF BIRTH", "BIRTH DATE"],
      "address" => ["ADDRESS", "ADDR", "STREET"],
      "license_number" => ["LICENSE NUMBER", "DL", "DL NO", "DRIVER LICENSE"]
    },
    "pay_stub" => {
      "employer_name" => ["EMPLOYER", "COMPANY", "EMPLOYER NAME"],
      "gross_income" => ["GROSS PAY", "GROSS EARNINGS", "TOTAL EARNINGS", "GROSS"],
      "pay_period" => ["PAY PERIOD", "PERIOD", "PAY DATE"],
      "net_income" => ["NET PAY", "NET EARNINGS", "TAKE HOME"]
    },
    "insurance" => {
      "policy_number" => ["POLICY NUMBER", "POLICY NO", "POLICY #"],
      "carrier" => ["CARRIER", "INSURER", "INSURANCE COMPANY", "COMPANY"],
      "coverage_start" => ["EFFECTIVE DATE", "START DATE", "EFF DATE"],
      "coverage_end" => ["EXPIRATION DATE", "END DATE", "EXP DATE"]
    }
  }.freeze

  def initialize(document_upload)
    @document_upload = document_upload
    @document_type = document_upload.document_type
  end

  def extract
    raise ExtractionError, "Invalid document type: #{@document_type}" unless DOCUMENT_TYPES.include?(@document_type)

    raw_fields = if mock_mode?
                   mock_extraction
                 else
                   textract_extraction
                 end

    mapped = map_fields(raw_fields)
    confidence = calculate_confidence(mapped)

    @document_upload.update!(
      status: confidence >= 0.7 ? "verified" : "needs_review",
      extracted_data: { raw: raw_fields, mapped: mapped, confidence: confidence }.to_json
    )

    { fields: mapped, confidence: confidence, status: @document_upload.status }
  rescue Aws::Textract::Errors::ServiceError => e
    @document_upload.update!(status: "failed", extracted_data: { error: e.message }.to_json)
    raise ExtractionError, "OCR extraction failed: #{e.message}"
  end

  private

  def mock_mode?
    ENV.fetch("MOCK_OCR", "true") == "true"
  end

  def mock_extraction
    case @document_type
    when "license"
      {
        "FIRST NAME" => "Jane",
        "LAST NAME" => "Smith",
        "DATE OF BIRTH" => "03/15/1990",
        "ADDRESS" => "456 Oak Avenue, Phoenix, AZ 85001",
        "DRIVER LICENSE" => "D12345678"
      }
    when "pay_stub"
      {
        "EMPLOYER" => "Acme Corporation",
        "GROSS PAY" => "$5,416.67",
        "PAY PERIOD" => "03/01/2026 - 03/15/2026",
        "NET PAY" => "$3,875.00"
      }
    when "insurance"
      {
        "POLICY NUMBER" => "AZ-INS-2026-78901",
        "CARRIER" => "State Farm",
        "EFFECTIVE DATE" => "01/01/2026",
        "EXPIRATION DATE" => "01/01/2027"
      }
    end
  end

  def textract_extraction
    require "aws-sdk-textract"

    client = Aws::Textract::Client.new(
      region: ENV.fetch("AWS_REGION", "us-east-1"),
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY")
    )

    image_bytes = if @document_upload.image.attached?
                    @document_upload.image.download
                  else
                    raise ExtractionError, "No image attached to document upload"
                  end

    response = client.analyze_document(
      document: { bytes: image_bytes },
      feature_types: ["FORMS"]
    )

    extract_key_value_pairs(response)
  end

  def extract_key_value_pairs(response)
    blocks = response.blocks
    key_map = {}
    value_map = {}
    block_map = {}

    blocks.each do |block|
      block_map[block.id] = block
      case block.block_type
      when "KEY_VALUE_SET"
        if block.entity_types&.include?("KEY")
          key_map[block.id] = block
        else
          value_map[block.id] = block
        end
      end
    end

    result = {}
    key_map.each_value do |key_block|
      key_text = get_text(key_block, block_map)
      value_block = find_value_block(key_block, value_map)
      value_text = value_block ? get_text(value_block, block_map) : ""
      result[key_text.strip.upcase] = value_text.strip if key_text.present?
    end

    result
  end

  def get_text(block, block_map)
    return "" unless block.relationships

    block.relationships
      .select { |r| r.type == "CHILD" }
      .flat_map(&:ids)
      .filter_map { |id| block_map[id] }
      .select { |b| b.block_type == "WORD" }
      .map(&:text)
      .join(" ")
  end

  def find_value_block(key_block, value_map)
    return nil unless key_block.relationships

    key_block.relationships
      .select { |r| r.type == "VALUE" }
      .flat_map(&:ids)
      .filter_map { |id| value_map[id] }
      .first
  end

  def map_fields(raw_fields)
    mapping = FIELD_MAPPINGS[@document_type] || {}
    result = {}

    mapping.each do |field_name, possible_keys|
      matched_key = possible_keys.find { |k| raw_fields.key?(k) }
      result[field_name] = raw_fields[matched_key] if matched_key
    end

    result
  end

  def calculate_confidence(mapped)
    expected = FIELD_MAPPINGS[@document_type]&.keys || []
    return 0.0 if expected.empty?

    found = mapped.keys.count { |k| mapped[k].present? }
    found.to_f / expected.length
  end
end
