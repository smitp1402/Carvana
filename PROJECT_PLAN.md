# Carvana AI Onboarding Enhancement — Project Plan

> Generated from PRD review on 2026-03-19

## 1. Product Overview

### Vision
A standalone demo prototype showing an AI-enhanced car buying onboarding experience — LLM chatbot guidance, OCR document auto-fill, and emotional support content layered over a 5-step financing flow. Built in 3 days for Gauntlet AI's Carvana hiring partner program.

### Target Users
- **Car Buyer** — primary conversion target; all 3 AI modules serve them directly
- **First-Time Buyer** — sub-variant with richer chatbot explanations and emotional support
- **Ops Staff** — benefits passively from cleaner submissions

### Key Outcomes
- Demonstrate measurable drop-off reduction through AI guidance at friction points
- Show real OCR extraction from uploaded documents (not mocked)
- Show real LLM chatbot responses (not scripted)
- Deploy a live demo URL for the hiring panel to interact with

---

## 2. Requirements Summary

### Functional Requirements

| ID | Domain | Requirement | Priority |
|----|--------|-------------|----------|
| FR-01 | Auth | User registration and login | Must-have |
| FR-02 | Auth | Identity verification via ID scan | Must-have |
| FR-03 | Auth | Session persistence — resume from exact step | Should-have |
| FR-04 | Chatbot | Guided form fill via conversational UI | Must-have |
| FR-05 | Chatbot | Document explainer — what each doc is and why | Must-have |
| FR-06 | Chatbot | Live Q&A — financing, delivery, trade-in questions | Must-have |
| FR-07 | Chatbot | Jargon simplifier — APR, LTV, GAP, DTI in plain English | Must-have |
| FR-08 | Chatbot | Drop-off re-engagement prompt | Should-have |
| FR-09 | Documents | Camera capture for mobile upload | Must-have |
| FR-10 | Documents | OCR extraction — driver's license | Must-have |
| FR-11 | Documents | OCR extraction — pay stubs | Must-have |
| FR-12 | Documents | OCR extraction — insurance documents | Must-have |
| FR-13 | Documents | Document validation (type, legibility, completeness) | Must-have |
| FR-14 | Documents | Proactive document checklist | Should-have |
| FR-15 | Emotional Support | "Why we ask this" micro-copy | Must-have |
| FR-16 | Emotional Support | Loan term visualizer (interactive slider) | Must-have |
| FR-17 | Emotional Support | Progress indicator with milestones | Should-have |
| FR-18 | Emotional Support | Purchase confidence prompts | Must-have |
| FR-19 | Vehicles | Mock vehicle inventory (3 seeded cars) | Must-have |
| FR-20 | Vehicles | Persistent vehicle summary card | Must-have |
| FR-21 | Core Flow | 5-step financing application | Must-have |
| FR-22 | Core Flow | Soft-pull credit pre-qualification simulation | Must-have |
| FR-23 | Core Flow | Pre-fill for returning users | Should-have |
| FR-24 | Ops | Application completeness dashboard | Should-have |
| FR-25 | Ops | Targeted document re-request with specific guidance | Should-have |
| FR-26 | Scheduling | Delivery / advisor call booking | Could-have |
| FR-27 | Auth | Co-applicant flow | Could-have |
| FR-28 | Core Flow | Trade-in transparency flow | Could-have |

### Non-Functional Requirements

| ID | Category | Requirement | Target |
|----|----------|-------------|--------|
| NFR-01 | Performance | OCR extraction time | < 3 seconds |
| NFR-02 | Performance | Chatbot response time | < 2 seconds |
| NFR-03 | Security | PII encryption | AES-256 at rest, TLS 1.3 in transit |
| NFR-04 | Security | SSN tokenization | Never store raw SSN |
| NFR-05 | Compliance | KYC standard | NIST 800-63-3 IAL2 |
| NFR-06 | Compliance | Federal lending | ECOA, FCRA, TILA, GLBA |
| NFR-07 | Compliance | California privacy | CCPA |
| NFR-08 | Reliability | Uptime | 99.9% |
| NFR-09 | Reliability | Session persistence | Resume from exact step |
| NFR-10 | Data Retention | Document lifecycle | 7-year retention, auto-purge |
| NFR-11 | Accessibility | WCAG | 2.1 AA |
| NFR-12 | Mobile | Responsive + camera | Mobile-first, iOS/Android camera |

### Assumptions
- Standalone prototype — no live Carvana API integration
- Mock vehicle data seeded in PostgreSQL (3 vehicles)
- Synchronous OCR processing (no background jobs for demo)
- Active Storage with local disk for dev, S3 for deployed demo
- Single developer, 3-day sprint

### Open Questions
- Should the chatbot have a named persona/avatar?
- AWS credentials available for Textract and S3?
- Anthropic API key available?

---

## 3. Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    BROWSER (Mobile / Desktop)                │
│                                                             │
│  ┌──────────────┐  ┌─────────────┐  ┌───────────────────┐  │
│  │  Vehicle     │  │  Chatbot    │  │  OCR Camera       │  │
│  │  Gallery     │  │  Widget     │  │  Capture          │  │
│  │(ViewComponent│  │(TypeScript/ │  │  (TypeScript/     │  │
│  │ + images)    │  │ ActionCable)│  │  MediaDevices)    │  │
│  └──────┬───────┘  └──────┬──────┘  └────────┬──────────┘  │
│         │                 │                   │             │
│  ┌──────▼─────────────────▼───────────────────▼──────────┐  │
│  │     Onboarding Flow (Rails ViewComponent + Turbo)     │  │
│  │  Step 1: Select Car                                   │  │
│  │  Step 2: Pre-Qualification                            │  │
│  │  Step 3: Financing Application                        │  │
│  │  Step 4: Document Upload + OCR                        │  │
│  │  Step 5: Review & Sign                                │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    RAILS BACKEND                             │
│                                                             │
│  Controllers:                                               │
│  ┌─────────────┐ ┌──────────────┐ ┌───────────────────────┐ │
│  │  Onboarding │ │  Chatbot     │ │  Documents            │ │
│  │  Controller │ │  Controller  │ │  Controller           │ │
│  └──────┬──────┘ └──────┬───────┘ └──────────┬────────────┘ │
│         │               │                    │              │
│  Services:              │                    │              │
│  ┌──────▼──────┐ ┌──────▼───────┐ ┌──────────▼────────────┐ │
│  │  Application│ │  LLM Service │ │  OCR Service          │ │
│  │  Service    │ │ (Claude API) │ │  (AWS Textract)       │ │
│  └──────┬──────┘ └──────────────┘ └───────────────────────┘ │
│         │                                                   │
│  ┌──────▼──────────────────────────────────────────────┐    │
│  │              PostgreSQL Database                     │    │
│  │  users │ vehicles │ applications │ documents │ chats │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐    │
│  │              Active Storage                          │    │
│  │  Vehicle images │ Uploaded documents (local/S3)     │    │
│  └──────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
            │                  │
            ▼                  ▼
   ┌──────────────┐   ┌──────────────────┐
   │  Anthropic   │   │  AWS Textract    │
   │  Claude API  │   │  + S3 (optional) │
   └──────────────┘   └──────────────────┘
```

### Component Breakdown

#### Onboarding Flow (ViewComponent + Turbo)
- **Responsibility:** Renders each of the 5 onboarding steps, manages step transitions, persists state to `OnboardingApplication`
- **Key interfaces:** `OnboardingApplication` state machine, `Vehicle` model
- **Technology:** Rails 7.2 ViewComponent, Turbo Frames for step transitions

#### Chatbot Widget (TypeScript + ActionCable)
- **Responsibility:** Real-time chat UI, streams LLM responses, maintains conversation context per session
- **Key interfaces:** `ChatbotController` (Rails), `LLMService`, `ChatMessage` model
- **Technology:** TypeScript, ActionCable WebSockets, Stimulus controller

#### OCR Camera Capture (TypeScript)
- **Responsibility:** Accesses device camera, captures document image, uploads to backend, displays extracted fields for confirmation
- **Key interfaces:** `DocumentsController`, `OCRService`
- **Technology:** TypeScript, MediaDevices API, fetch API

#### Loan Visualizer (TypeScript)
- **Responsibility:** Interactive slider showing monthly payment based on vehicle price, loan term, down payment, APR
- **Key interfaces:** Vehicle price from `OnboardingApplication`
- **Technology:** TypeScript Stimulus controller, pure calculation (no external API)

#### LLM Service (Ruby)
- **Responsibility:** Constructs system prompt with onboarding context, calls Claude API, streams response tokens
- **Key interfaces:** `Anthropic::Client`, `ChatMessage` model, `OnboardingApplication` context
- **Technology:** Ruby, `anthropic` gem (or raw HTTP via `faraday`)

#### OCR Service (Ruby)
- **Responsibility:** Uploads document image to Textract, receives extracted key-value pairs, maps to application fields
- **Key interfaces:** `aws-sdk-textract` gem, `DocumentUpload` model
- **Technology:** Ruby, `aws-sdk-textract` gem

### Data Models

#### User
```ruby
id              :bigint
email           :string       # encrypted
password_digest :string       # Devise
first_name      :string
last_name       :string
experience_level :string      # 'first_time' | 'experienced'
created_at      :datetime
updated_at      :datetime
```

#### Vehicle
```ruby
id          :bigint
make        :string        # Honda
model       :string        # Accord
year        :integer       # 2024
price       :decimal       # 28990.00
mileage     :integer       # 42000
color       :string        # Silver
stock_no    :string        # CV-84729
description :text
created_at  :datetime
```

#### OnboardingApplication
```ruby
id                  :bigint
user_id             :bigint
vehicle_id          :bigint
current_step        :integer    # 1-5
status              :string     # 'in_progress' | 'submitted' | 'approved'
# Step 2: Pre-qual
annual_income       :decimal
employment_status   :string
employer_name       :string
# Step 3: Financing
loan_term_months    :integer
down_payment        :decimal
requested_apr       :decimal
# Step 4: Documents
license_verified    :boolean
income_verified     :boolean
insurance_verified  :boolean
# Step 5: Review
signed_at           :datetime
created_at          :datetime
updated_at          :datetime
```

#### DocumentUpload
```ruby
id              :bigint
application_id  :bigint
document_type   :string    # 'license' | 'pay_stub' | 'insurance'
status          :string    # 'pending' | 'processing' | 'verified' | 'rejected'
rejection_reason :string
extracted_fields :jsonb    # raw Textract output
created_at      :datetime
```

#### ChatMessage
```ruby
id              :bigint
application_id  :bigint
role            :string    # 'user' | 'assistant'
content         :text
step_context    :integer   # which onboarding step this was sent on
created_at      :datetime
```

### API Surface

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /vehicles | List mock vehicle inventory | No |
| GET | /vehicles/:id | Vehicle detail | No |
| POST | /auth/signup | Register new user | No |
| POST | /auth/login | Login | No |
| POST | /onboarding | Create new application | Yes |
| GET | /onboarding/:id | Get application state | Yes |
| PATCH | /onboarding/:id/step/:n | Update step data | Yes |
| POST | /onboarding/:id/documents | Upload document for OCR | Yes |
| GET | /onboarding/:id/documents/:doc_id | Get OCR extraction result | Yes |
| POST | /chatbot/messages | Send chat message (streams response) | Yes |
| GET | /ops/applications | Ops dashboard — all applications | Admin |

### Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Backend | Ruby on Rails 7.2 | Required stack — fast for form-heavy flows |
| Frontend components | ViewComponent 3.x | Encapsulated, testable UI components in Rails |
| Frontend interactivity | TypeScript + Stimulus 3 | Lightweight, Rails-native, no separate SPA build |
| Real-time chat | ActionCable (WebSockets) | Built into Rails — zero extra infrastructure |
| Auth | Devise 4.9 | Battle-tested Rails auth gem |
| Database | PostgreSQL 16 | Rails default, JSONB for OCR output |
| Styling | Tailwind CSS 3.x | Rapid mobile-first UI development |
| LLM | Anthropic Claude API (claude-sonnet-4-6) | Best instruction-following, compliance-safe |
| OCR | AWS Textract | Highest accuracy on financial docs, SOC2 compliant |
| File storage | Active Storage + Local/S3 | Rails native, easy to swap local→S3 for deploy |
| Deployment | Render.com (free tier) | Simple Rails deploy, free PostgreSQL |

### Detected Stack Constraints
Required stack: Ruby on Rails + TypeScript/JavaScript. All recommendations fit within this constraint. Greenfield project — no existing dependencies to inherit.

### Shared Interfaces

| Interface | Location | Purpose | Depended on by |
|-----------|----------|---------|----------------|
| `User` | `app/models/user.rb` | Identity, auth, experience level flag | Auth, Chatbot, Onboarding, OCR |
| `OnboardingApplication` | `app/models/onboarding_application.rb` | Core state machine — current step, all collected data | All onboarding steps, Chatbot context |
| `LLMService` | `app/services/llm_service.rb` | Claude API wrapper — prompt construction, streaming | Chatbot controller, Jargon explainer |
| `OCRService` | `app/services/ocr_service.rb` | Textract wrapper — upload, extract, map fields | Documents controller |
| `DocumentUpload` | `app/models/document_upload.rb` | Document metadata, S3 ref, validation state | OCR, Ops dashboard |
| `ApplicationContext` | `app/services/application_context.rb` | Builds LLM system prompt from current application state | LLMService — ensures chatbot knows what step user is on |

---

## 4. Strategy

### Build vs. Buy
| Capability | Decision | Rationale |
|-----------|----------|-----------|
| LLM / Chatbot | Buy (Anthropic Claude API) | Building an LLM is not the product |
| OCR / Document scanning | Buy (AWS Textract) | Accuracy on financial docs requires specialized ML |
| Authentication | Build (Devise gem) | Standard Rails auth — full compliance control |
| Loan payment calculator | Build | Simple formula — no library needed |
| Vehicle 360 viewer | Skip for v1 | Image gallery sufficient for 3-day demo |
| Document storage | Buy (Active Storage + S3) | Encrypted, compliant, zero infra overhead |
| Session persistence | Build | Custom state machine on `OnboardingApplication` |

### MVP Scope
**In for 3-day sprint:**
- Auth (Devise)
- 3 seeded mock vehicles with images
- 5-step onboarding flow
- Real AI chatbot (Claude API + ActionCable streaming)
- Real OCR (AWS Textract — license, pay stub, insurance)
- Emotional support: loan visualizer, micro-copy, confidence prompts, progress indicator
- Session persistence (resume from step)

**Explicitly deferred:**
- Ops staff dashboard
- Co-applicant flow
- Trade-in transparency flow
- Intelligent scheduling
- State-specific DMV compliance rules
- 360° vehicle viewer

### Iteration Approach
After demo: gather hiring panel feedback, prioritize ops dashboard and trade-in flow for v2, add real Carvana API integration if partnership develops.

### Deployment Strategy
Deploy to Render.com free tier. PostgreSQL via Render managed database. Active Storage pointing to AWS S3 for documents. Environment variables for API keys. Single Procfile deployment.

---

## 5. Project Structure

```
carvana-ai-onboarding/
├── app/
│   ├── components/           # ViewComponent UI components
│   │   ├── onboarding/
│   │   │   ├── step_one_component.rb       # Vehicle selection
│   │   │   ├── step_two_component.rb       # Pre-qualification
│   │   │   ├── step_three_component.rb     # Financing form
│   │   │   ├── step_four_component.rb      # Document upload
│   │   │   └── step_five_component.rb      # Review & sign
│   │   ├── chatbot_widget_component.rb
│   │   ├── loan_visualizer_component.rb
│   │   └── vehicle_card_component.rb
│   ├── controllers/
│   │   ├── onboarding_controller.rb
│   │   ├── chatbot_controller.rb
│   │   ├── documents_controller.rb
│   │   └── vehicles_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── vehicle.rb
│   │   ├── onboarding_application.rb
│   │   ├── document_upload.rb
│   │   └── chat_message.rb
│   ├── services/
│   │   ├── llm_service.rb
│   │   ├── ocr_service.rb
│   │   ├── application_context.rb
│   │   └── document_validator.rb
│   ├── channels/
│   │   └── chatbot_channel.rb              # ActionCable WebSocket
│   ├── javascript/
│   │   ├── controllers/
│   │   │   ├── chatbot_controller.ts       # Chat UI + streaming
│   │   │   ├── ocr_capture_controller.ts   # Camera capture
│   │   │   └── loan_visualizer_controller.ts
│   │   └── application.ts
│   └── views/
│       ├── vehicles/
│       ├── onboarding/
│       └── layouts/
├── db/
│   ├── migrate/
│   └── seeds.rb                            # 3 vehicles + demo user
├── spec/                                   # RSpec tests
├── config/
│   ├── routes.rb
│   └── credentials.yml.enc                 # API keys (encrypted)
├── Gemfile
├── package.json
└── Procfile                                # Render deployment
```

---

## 6. Implementation Plan

### Timeline
- **Start date:** 2026-03-19
- **Target completion:** 2026-03-22 (3 days)
- **Total estimated duration:** 3 days

---

### Phase 1: Foundation — Day 1 Morning (4 hours)

**Goal:** Rails app running with auth, database, vehicles, and the onboarding form skeleton

**Deliverables:**
- [x] Rails 7.2 app created with PostgreSQL, Tailwind, ViewComponent, Devise
- [x] Vehicle model + migration + seed data (3 cars with images)
- [x] User model + Devise auth (signup, login, sessions)
- [x] OnboardingApplication model + state machine (5 steps)
- [x] Vehicles index page (browse inventory)
- [x] 5-step onboarding flow scaffold (empty steps, navigation working)
- [x] Persistent vehicle summary card throughout flow
- [x] Progress indicator component

**Key Tasks:**
1. `rails new carvana-ai-onboarding --database=postgresql --asset-pipeline=propshaft`
2. Add gems: `devise`, `view_component`, `tailwindcss-rails`, `anthropic`, `aws-sdk-textract`
3. Run Devise install, generate User model
4. Generate Vehicle, OnboardingApplication, DocumentUpload, ChatMessage migrations
5. Create `db/seeds.rb` with 3 vehicles (Honda Accord, Toyota Camry, Ford Explorer) and demo user
6. Build VehiclesController and index view (card grid)
7. Build OnboardingController with step routing (`/onboarding/:id/step/:n`)
8. Create ViewComponent for each step (empty shells)
9. Build VehicleCardComponent (persistent sidebar/header)
10. Build ProgressIndicatorComponent (5 steps, current step highlighted)

**Success Criteria:**
- `rails db:seed` populates 3 vehicles and a demo user
- User can browse vehicles, click "Start Purchase", and navigate through all 5 steps
- Vehicle card visible on every step
- Progress indicator updates on each step

**Risks:**
- Devise setup takes longer than expected — use `devise_token_auth` only if needed for API; standard Devise is sufficient

---

### Phase 2: AI Chatbot — Day 1 Afternoon (4 hours)

**Goal:** Working real-time chatbot powered by Claude API, streaming responses, context-aware

**Deliverables:**
- [x] `LLMService` — Claude API wrapper with system prompt construction
- [x] `ApplicationContext` service — builds chatbot context from current application state
- [x] `ChatbotChannel` — ActionCable channel for WebSocket streaming
- [x] ChatMessage model populated per session
- [x] Chatbot widget TypeScript controller (UI + streaming display)
- [x] Chatbot widget ViewComponent (chat bubble, input, message list)
- [x] Jargon simplifier — APR, LTV, GAP, DTI explanations in system prompt
- [x] "Why we ask this" micro-copy on each sensitive form field

**Key Tasks:**
1. Create `app/services/llm_service.rb` with `call(messages:, context:)` method
2. Build system prompt template:
   ```
   You are an AI onboarding assistant helping [user_name] purchase a [vehicle].
   They are on Step [n] of 5: [step_name].
   Current application data: [serialized fields].
   Help them complete this step. Explain financial terms simply.
   Never fabricate loan approval decisions or credit scores.
   ```
3. Create `app/channels/chatbot_channel.rb` — subscribe by application ID
4. Build `app/javascript/controllers/chatbot_controller.ts` — connects to ActionCable, renders streamed tokens
5. Build `ChatbotWidgetComponent` — floating chat panel, message bubbles, input field
6. Add "Why we ask this" data attributes to each form field, rendered as tooltip by Stimulus

**Success Criteria:**
- User sends a message and receives a streaming Claude response within 2 seconds
- Chatbot knows what step the user is on and what vehicle they're purchasing
- "Why we ask this" tooltips visible on all sensitive fields (SSN, income, employer)
- Jargon terms (APR, LTV, GAP) trigger plain-English explanations

**Risks:**
- ActionCable streaming with Claude's streaming API requires careful token buffering — test early
- If streaming is complex, fall back to non-streaming (single response) for demo

---

### Phase 3: OCR Document Scanning — Day 2 Morning (4 hours)

**Goal:** Real AWS Textract integration — user points camera at document, fields auto-populate

**Deliverables:**
- [x] `OCRService` — Textract wrapper with field extraction and mapping
- [x] `DocumentValidator` service — checks document type, legibility, required fields present
- [x] DocumentUpload model populated with extraction results
- [x] OCR camera capture TypeScript controller (MediaDevices API)
- [x] Step 4 (Document Upload) ViewComponent with camera UI
- [x] Field auto-population after successful OCR extraction
- [x] Proactive document checklist shown at start of Step 4
- [x] Specific error messages for failed/wrong document uploads

**Key Tasks:**
1. Create `app/services/ocr_service.rb`:
   - Upload image to S3 (or pass bytes directly to Textract)
   - Call `Aws::Textract::Client#analyze_document`
   - Map extracted key-value pairs to application fields
2. Build field mappers per document type:
   - License → `first_name`, `last_name`, `dob`, `address`, `license_number`
   - Pay stub → `employer_name`, `gross_income`, `pay_period`
   - Insurance → `policy_number`, `carrier`, `coverage_start`, `coverage_end`
3. Create `app/javascript/controllers/ocr_capture_controller.ts`:
   - Request camera permission via `navigator.mediaDevices.getUserMedia`
   - Show live viewfinder, capture button
   - Upload captured image via `fetch` to `/onboarding/:id/documents`
   - Receive extracted fields JSON, animate form field population
4. Build `DocumentValidator` — reject if wrong MIME type, too small (<50KB), or key fields missing
5. Build proactive checklist ViewComponent shown before upload begins

**Success Criteria:**
- User can capture document via camera on mobile
- Driver's license scan auto-fills name, DOB, address with > 85% accuracy
- Wrong document type shows specific error (not generic "upload failed")
- Checklist clearly lists required documents before step begins

**Risks:**
- Textract accuracy varies by document quality — add fallback manual entry if extraction confidence < 70%
- Camera access requires HTTPS — ensure local dev uses `localhost` (browsers allow camera on localhost)

---

### Phase 4: Emotional Support Layer — Day 2 Afternoon (3 hours)

**Goal:** Loan visualizer, confidence prompts, and purchase anxiety reduction throughout the flow

**Deliverables:**
- [ ] Loan visualizer TypeScript component (slider: term, down payment → monthly payment)
- [ ] Confidence prompt system — contextual messages at Step 2 (pre-qual), Step 3 (financing), Step 5 (sign)
- [ ] Drop-off re-engagement — detect 3-minute inactivity, show chatbot prompt
- [ ] Session persistence — user can close browser and resume from exact step
- [ ] "You're almost there" milestone messages

**Key Tasks:**
1. Build `app/javascript/controllers/loan_visualizer_controller.ts`:
   - Inputs: vehicle price (from seed), loan term (select), down payment (input), APR (from pre-qual result)
   - Formula: `M = P[r(1+r)^n]/[(1+r)^n-1]` where r = monthly rate, n = term months
   - Live update on slider change
2. Add confidence prompts as ViewComponent — triggered per step:
   - Step 2: "This soft credit check won't affect your credit score"
   - Step 3: "You can adjust your loan terms at any time before signing"
   - Step 5: "100-day / 4,189-mile return policy included with every purchase"
3. Add inactivity detection in `chatbot_controller.ts` — after 3 min idle, push message: "Still thinking? I can help explain anything on this page."
4. Ensure `OnboardingApplication#current_step` is saved on every step submission — browser close + revisit resumes correctly

**Success Criteria:**
- Loan visualizer updates monthly payment in real-time as user adjusts term/down payment
- Confidence prompts visible at Steps 2, 3, and 5
- Closing and reopening the browser resumes at the correct step
- Idle prompt fires after 3 minutes of inactivity

**Risks:**
- APR for the loan visualizer is simulated — clearly label as "estimated" to avoid compliance issues

---

### Phase 5: Polish + Deploy — Day 3 (8 hours)

**Goal:** Demo-ready UI, end-to-end flow working, deployed to a live URL

**Deliverables:**
- [ ] Tailwind UI polish — consistent spacing, typography, mobile layout
- [ ] Mobile camera flow tested on iOS Safari and Android Chrome
- [ ] Demo user seeded (email: `demo@carvana.com`, password: `demo1234`)
- [ ] End-to-end flow tested: signup → browse → select car → 5 steps → submitted
- [ ] Render.com deployment with environment variables configured
- [ ] Live demo URL working
- [ ] README with setup instructions and demo flow walkthrough

**Key Tasks:**
1. Polish Step 1 (vehicle cards) — image, price, key specs, "Start Purchase" CTA
2. Polish Step 3 (financing) — loan visualizer prominent, confidence prompts styled
3. Polish Step 4 (documents) — camera UI with clear instructions, checklist styled
4. Polish chatbot widget — fixed position, mobile-friendly, avatar icon
5. Test full flow on mobile (iOS Safari) — camera capture, form fill, chatbot
6. Create `render.yaml` or configure Render dashboard:
   - Web service: `bundle exec puma -C config/puma.rb`
   - Database: Render PostgreSQL (free tier)
   - Env vars: `ANTHROPIC_API_KEY`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
7. Run `rails assets:precompile` and verify no JS errors
8. Write `README.md` with: setup, env vars, seed instructions, demo walkthrough

**Success Criteria:**
- Full flow completable on mobile in under 10 minutes
- Chatbot responds with context about the selected vehicle
- OCR extracts at least name and DOB from a driver's license scan
- Live URL accessible for hiring panel
- No unhandled errors in production logs

**Risks:**
- Render free tier cold start — add a note in README to wait 30s on first load
- AWS Textract requires a real document for full extraction — prepare a sample document for demo

---

## 7. Cost Analysis

### Development Costs (3-day sprint)

| Phase | Effort | Paid Tools | Cost |
|-------|--------|-----------|------|
| Phase 1: Foundation | 4 hours | None | $0 |
| Phase 2: Chatbot | 4 hours | Anthropic API (~100 test calls) | ~$1 |
| Phase 3: OCR | 4 hours | AWS Textract (~30 test scans @ $0.015/page) | ~$0.45 |
| Phase 4: Emotional Support | 3 hours | None | $0 |
| Phase 5: Polish + Deploy | 8 hours | AWS S3 (< 1GB) | ~$0.02 |
| **Total** | **23 hours** | | **~$1.50** |

*Demo costs are negligible. All services have generous free tiers for low-volume testing.*

### Operational Costs at Scale (if productionized)

| Component | 1K users/mo | 10K users/mo | 100K users/mo |
|-----------|------------|--------------|---------------|
| Anthropic Claude API (~10 messages/user) | ~$50 | ~$500 | ~$5,000 |
| AWS Textract (~3 docs/user @ $0.015/page) | ~$45 | ~$450 | ~$4,500 |
| AWS S3 + bandwidth | ~$5 | ~$30 | ~$200 |
| Render/Heroku compute | ~$25 | ~$100 | ~$500 |
| PostgreSQL (managed) | ~$10 | ~$50 | ~$200 |
| **Monthly Total** | **~$135** | **~$1,130** | **~$10,400** |

### Alternative Cost Comparison

#### LLM Provider

| Option | Monthly @ 1K users | Monthly @ 100K users | Notes |
|--------|-------------------|---------------------|-------|
| **Anthropic Claude (chosen)** | ~$50 | ~$5,000 | Best compliance posture |
| OpenAI GPT-4o | ~$60 | ~$6,000 | Slightly higher cost, strong ecosystem |
| Self-hosted Llama 3 | ~$200 (GPU infra) | ~$800 (GPU infra) | No per-token cost but high fixed infra cost; breaks even at ~50K users |

#### OCR Provider

| Option | Monthly @ 1K users | Monthly @ 100K users | Notes |
|--------|-------------------|---------------------|-------|
| **AWS Textract (chosen)** | ~$45 | ~$4,500 | Best accuracy on financial docs |
| Google Document AI | ~$40 | ~$4,000 | Slightly cheaper, comparable accuracy |
| Azure Form Recognizer | ~$38 | ~$3,800 | Best value if already on Azure |

---

## 8. Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| Textract accuracy low on demo documents | High | Medium | Prepare high-quality sample docs; add manual entry fallback |
| ActionCable streaming complexity blocks Day 1 | High | Medium | Fall back to non-streaming (polling) if needed for demo |
| AWS credentials not available in time | High | Low | Prepare mock OCR responses as fallback — hardcode extraction for specific test docs |
| Render.com cold start makes demo feel broken | Medium | High | Add loading state; note in README; consider paid tier if budget allows |
| Camera access blocked on test device | Medium | Medium | Test on real device early; prepare file upload fallback |
| 3-day timeline slips | High | Medium | Phase 5 (polish) is compressible — core AI modules (2+3) are non-negotiable |

---

## 9. Next Steps

1. Run `/implement` to begin the 3-day sprint following this plan phase by phase
2. Confirm API keys available: `ANTHROPIC_API_KEY`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
3. Run `/review` after implementation to verify all must-have requirements are met
4. Run `/test-qa` at Low stakes level — smoke tests + core happy path
5. Run `/ship` to deploy to Render.com and generate live demo URL
