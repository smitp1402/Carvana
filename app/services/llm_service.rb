class LlmService
  API_URL = "https://api.anthropic.com/v1/messages".freeze
  MODEL = "claude-sonnet-4-6-20250514".freeze
  MAX_TOKENS = 512

  class ApiError < StandardError; end

  def initialize(application)
    @application = application
    @context = ApplicationContext.new(application)
  end

  def call(user_message)
    messages = build_messages(user_message)
    response = send_request(messages)
    extract_content(response)
  end

  def stream(user_message, &block)
    messages = build_messages(user_message)
    stream_request(messages, &block)
  end

  private

  def build_messages(user_message)
    history = @application.chat_messages
      .order(created_at: :asc)
      .last(20)
      .map { |msg| { role: msg.role, content: msg.content } }

    # Anthropic API requires strict user/assistant alternation starting with user
    history = history.drop_while { |m| m[:role] == "assistant" }

    # Remove consecutive same-role messages
    deduped = []
    history.each do |msg|
      next if deduped.last && deduped.last[:role] == msg[:role]
      deduped << msg
    end

    deduped + [{ role: "user", content: user_message }]
  end

  def send_request(messages)
    conn = Faraday.new(url: API_URL) do |f|
      f.request :json
      f.response :json
      f.options.timeout = 30
      f.options.open_timeout = 10
    end

    response = conn.post do |req|
      req.headers["x-api-key"] = api_key
      req.headers["anthropic-version"] = "2023-06-01"
      req.headers["content-type"] = "application/json"
      req.body = {
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: @context.build_system_prompt,
        messages: messages
      }
    end

    unless response.success?
      raise ApiError, "Claude API error: #{response.status} — #{response.body}"
    end

    response.body
  end

  def stream_request(messages, &block)
    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30
    http.open_timeout = 10

    request = Net::HTTP::Post.new(uri)
    request["x-api-key"] = api_key
    request["anthropic-version"] = "2023-06-01"
    request["content-type"] = "application/json"
    request["accept"] = "text/event-stream"
    request.body = {
      model: MODEL,
      max_tokens: MAX_TOKENS,
      stream: true,
      system: @context.build_system_prompt,
      messages: messages
    }.to_json

    full_text = ""

    http.request(request) do |response|
      unless response.code.to_i == 200
        raise ApiError, "Claude API error: #{response.code} — #{response.body}"
      end

      buffer = ""
      response.read_body do |chunk|
        buffer += chunk
        while (line_end = buffer.index("\n"))
          line = buffer.slice!(0, line_end + 1).strip
          next if line.empty? || line.start_with?("event:")

          if line.start_with?("data: ")
            json_str = line.sub("data: ", "")
            next if json_str == "[DONE]"

            begin
              data = JSON.parse(json_str)
              if data["type"] == "content_block_delta" && data.dig("delta", "text")
                text = data["delta"]["text"]
                full_text += text
                block.call(text)
              end
            rescue JSON::ParserError
              next
            end
          end
        end
      end
    end

    full_text
  end

  def extract_content(response)
    content = response.dig("content", 0, "text")
    raise ApiError, "No content in Claude response" unless content
    content
  end

  def api_key
    @api_key ||= ENV.fetch("ANTHROPIC_API_KEY") do
      raise ApiError, "ANTHROPIC_API_KEY environment variable is not set"
    end
  end
end
