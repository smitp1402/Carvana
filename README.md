# Carvana AI Onboarding

AI-enhanced car buying onboarding experience with LLM chatbot guidance, OCR document auto-fill, and emotional support content layered over a 5-step financing flow.

Built for Gauntlet AI's Carvana hiring partner program.

## Features

- **AI Chatbot** — Claude-powered assistant that guides users through each step, explains financial terms in plain English, and answers questions in real-time with streaming responses
- **OCR Document Scanning** — Camera capture extracts data from driver's licenses, pay stubs, and insurance cards to auto-fill forms (AWS Textract with mock mode for demo)
- **5-Step Financing Flow** — Pre-qualification, financing details, document upload, review & sign, completion
- **Emotional Support Layer** — Confidence prompts, "Why we ask this" micro-copy, loan term visualizer, milestone messages, and inactivity re-engagement
- **Session Persistence** — Close the browser and resume exactly where you left off

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Ruby on Rails 8.1 |
| Auth | Devise |
| Database | SQLite3 (dev) / PostgreSQL (production) |
| Styling | Tailwind CSS |
| LLM | Anthropic Claude API (claude-sonnet-4-6) |
| OCR | AWS Textract (with mock mode) |
| Deployment | Render.com |

## Setup

### Prerequisites

- Ruby 3.3+
- Node.js 20+ (for Tailwind CSS build)
- SQLite3

### Install

```bash
bundle install
rails db:create db:migrate db:seed
```

### Environment Variables

Copy `.env.example` to `.env` and fill in:

```
ANTHROPIC_API_KEY=sk-ant-...    # Required for chatbot
MOCK_OCR=true                    # Set to false for real Textract
AWS_ACCESS_KEY_ID=               # Required if MOCK_OCR=false
AWS_SECRET_ACCESS_KEY=           # Required if MOCK_OCR=false
AWS_REGION=us-east-1
```

### Run

```bash
bin/dev
```

Visit `http://localhost:3000`

## Demo Walkthrough

### Demo User

- Email: `demo@carvana.com`
- Password: `demo1234`

### Flow

1. **Browse Vehicles** — View 3 seeded cars on the home page
2. **Start Purchase** — Click "Start Purchase" on any vehicle (requires sign-in)
3. **Step 1: Pre-Qualification** — Enter income and employment info. Chat with the AI assistant.
4. **Step 2: Financing** — Adjust loan term and down payment with interactive sliders. See monthly payment update in real-time.
5. **Step 3: Documents** — Click "Scan" to capture documents via camera (or "Upload" for file picker). On demo, mock OCR returns realistic extraction data.
6. **Step 4: Review & Sign** — Review all collected data and submit.
7. **Step 5: Complete** — See confirmation and next steps.

### AI Chatbot Tips

- Click the quick-suggestion buttons for guided interaction
- Ask about financial terms: "What is APR?", "What is GAP insurance?"
- Ask step-specific questions: "Why do you need my income?", "What happens after I submit?"
- The chatbot knows which vehicle you're buying and what step you're on

## Deployment (Render.com)

1. Push to GitHub
2. Connect repo on Render.com
3. Use `render.yaml` for Infrastructure as Code, or manually create:
   - **Web Service**: Ruby, free tier
   - **Database**: PostgreSQL, free tier
4. Set environment variables: `RAILS_MASTER_KEY`, `ANTHROPIC_API_KEY`
5. First deploy will run migrations and seed data automatically

Note: Render free tier has cold starts (~30s on first load after inactivity).

## Project Structure

```
app/
  controllers/
    chat_messages_controller.rb    # AI chatbot (streaming SSE)
    document_uploads_controller.rb # OCR document upload
    onboarding_applications_controller.rb  # 5-step flow
    vehicles_controller.rb         # Vehicle inventory
  models/
    user.rb                        # Devise auth + experience level
    vehicle.rb                     # 3 seeded cars
    onboarding_application.rb      # State machine (5 steps)
    document_upload.rb             # OCR extraction results
    chat_message.rb                # Chat history
  services/
    llm_service.rb                 # Claude API wrapper (sync + streaming)
    application_context.rb         # System prompt builder
    ocr_service.rb                 # AWS Textract + mock mode
    document_validator.rb          # File validation
  views/
    onboarding_applications/
      _chatbot_widget.html.erb     # Reusable chat UI with streaming
      _progress.html.erb           # Step progress indicator
      _vehicle_card.html.erb       # Persistent vehicle summary
      step1-5.html.erb             # Onboarding step views
```
