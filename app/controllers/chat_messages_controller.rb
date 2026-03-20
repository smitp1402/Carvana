class ChatMessagesController < ApplicationController
  include ActionController::Live

  before_action :authenticate_user!
  before_action :set_application

  def create
    user_message = params[:message].to_s.strip
    if user_message.blank?
      render json: { error: "Message cannot be empty" }, status: :unprocessable_entity
      return
    end

    if user_message.length > 2000
      render json: { error: "Message too long (max 2000 characters)" }, status: :unprocessable_entity
      return
    end

    @application.chat_messages.create!(
      role: "user",
      content: user_message,
      step_context: params[:step].to_s
    )

    if params[:stream] == "true"
      stream_response(user_message)
    else
      sync_response(user_message)
    end
  end

  private

  def set_application
    @application = current_user.onboarding_applications.find(params[:application_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Application not found" }, status: :not_found
  end

  def sync_response(user_message)
    service = LlmService.new(@application)
    assistant_reply = service.call(user_message)

    @application.chat_messages.create!(
      role: "assistant",
      content: assistant_reply,
      step_context: params[:step].to_s
    )

    render json: { role: "assistant", content: assistant_reply }
  rescue LlmService::ApiError => e
    Rails.logger.error("LLM Service error: #{e.message}")
    render json: { role: "assistant", content: fallback_message }, status: :ok
  end

  def stream_response(user_message)
    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["Connection"] = "keep-alive"
    response.headers["X-Accel-Buffering"] = "no"

    service = LlmService.new(@application)
    full_text = ""

    begin
      full_text = service.stream(user_message) do |token|
        response.stream.write("data: #{{ token: token }.to_json}\n\n")
      end

      response.stream.write("data: #{{ done: true }.to_json}\n\n")

      @application.chat_messages.create!(
        role: "assistant",
        content: full_text,
        step_context: params[:step].to_s
      )
    rescue LlmService::ApiError => e
      Rails.logger.error("LLM Stream error: #{e.message}")
      response.stream.write("data: #{{ token: fallback_message, done: true }.to_json}\n\n")
    rescue ActionController::Live::ClientDisconnected
      Rails.logger.info("Client disconnected during stream")
      if full_text.present?
        @application.chat_messages.create!(
          role: "assistant",
          content: full_text,
          step_context: params[:step].to_s
        )
      end
    ensure
      response.stream.close
    end
  end

  def fallback_message
    "I'm having a little trouble connecting right now. You can continue filling out the form — I'll be back shortly!"
  end
end
