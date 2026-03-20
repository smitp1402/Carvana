class ApplicationContext
  STEP_DESCRIPTIONS = {
    1 => "Pre-Qualification — collecting income and employment info for a soft credit check",
    2 => "Financing Details — choosing loan term, down payment, and providing SSN for credit application",
    3 => "Document Upload — scanning driver's license, pay stub, and insurance card via camera/OCR",
    4 => "Review & Sign — reviewing all application details before final submission",
    5 => "Complete — application has been submitted successfully"
  }.freeze

  JARGON_DEFINITIONS = {
    "APR" => "Annual Percentage Rate — the yearly cost of your loan including interest and fees. Lower is better.",
    "LTV" => "Loan-to-Value ratio — the loan amount divided by the car's value. Below 100% means you have equity.",
    "GAP" => "Guaranteed Asset Protection — insurance that covers the difference between what you owe and what the car is worth if it's totaled.",
    "DTI" => "Debt-to-Income ratio — your total monthly debt payments divided by your gross monthly income. Lenders prefer under 43%.",
    "soft pull" => "A credit check that does NOT affect your credit score. Used for pre-qualification only.",
    "hard pull" => "A credit check that may slightly lower your score (usually 5-10 points). Only happens when you formally apply for a loan."
  }.freeze

  def initialize(application)
    @application = application
    @user = application.user
    @vehicle = application.vehicle
  end

  def build_system_prompt
    <<~PROMPT
      You are a friendly, knowledgeable AI assistant helping #{user_name} purchase a #{vehicle_description}.

      CURRENT STATE:
      - Step #{@application.current_step} of 5: #{STEP_DESCRIPTIONS[@application.current_step]}
      - Application status: #{@application.status}
      #{application_data_summary}

      VEHICLE DETAILS:
      - #{@vehicle.display_name} (#{@vehicle.year})
      - Price: #{@vehicle.formatted_price}
      - Mileage: #{@vehicle.formatted_mileage}
      - Color: #{@vehicle.color}

      FINANCIAL JARGON REFERENCE (explain these simply when relevant):
      #{jargon_reference}

      GUIDELINES:
      - Be warm, encouraging, and concise (2-3 sentences max per response).
      - If the user seems anxious about finances, reassure them — this is normal.
      - Explain financial terms in plain English when they come up.
      - Guide them through the current step. Don't skip ahead.
      - Never fabricate loan approval decisions, credit scores, or specific rates.
      - If asked about something outside car buying, gently redirect.
      - Use a conversational tone, not corporate-speak.
      #{first_time_buyer_guidance}
    PROMPT
  end

  private

  def user_name
    @user.full_name.presence || @user.email.split("@").first
  end

  def vehicle_description
    "#{@vehicle.year} #{@vehicle.make} #{@vehicle.model}"
  end

  def application_data_summary
    data = @application.data
    return "" if data.empty?

    lines = []
    lines << "- Annual income: $#{data['annual_income']}" if data["annual_income"].present?
    lines << "- Employment: #{data['employment_status']}" if data["employment_status"].present?
    lines << "- Employer: #{data['employer_name']}" if data["employer_name"].present?
    lines << "- Loan term: #{data['loan_term']} months" if data["loan_term"].present?
    lines << "- Down payment: $#{data['down_payment']}" if data["down_payment"].present?

    return "" if lines.empty?
    "\nCOLLECTED DATA:\n#{lines.join("\n")}"
  end

  def jargon_reference
    JARGON_DEFINITIONS.map { |term, definition| "- #{term}: #{definition}" }.join("\n")
  end

  def first_time_buyer_guidance
    return "" unless @user.first_time_buyer?

    <<~GUIDANCE
      FIRST-TIME BUYER NOTE:
      This user is a first-time car buyer. Be extra patient and explain each step thoroughly.
      Proactively explain why each piece of information is needed.
      Offer encouragement — buying your first car is exciting but can feel overwhelming.
    GUIDANCE
  end
end
