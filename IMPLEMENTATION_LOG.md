# Implementation Log

## Phase 1: Foundation — 2026-03-20
- **Status:** Complete
- **Deliverables:** 8/8 complete
- **Deviations:**
  - Used Rails 8.1 instead of 7.2 (minor — newer version, same APIs)
  - Used SQLite3 instead of PostgreSQL for development (minor — easier local setup, PostgreSQL for production)
  - Ford Explorer changed to Ford Mustang GT in seed data (minor — cosmetic)
  - No package.json or JS build pipeline — using inline scripts and propshaft (minor — simpler for demo)
- **Notes:** ViewComponent gem installed but not used as standalone components; step views use partials instead.

## Phase 2: AI Chatbot — 2026-03-20
- **Status:** Complete
- **Deliverables:** 8/8 complete
- **Deviations:**
  - Used SSE streaming via ActionController::Live instead of ActionCable WebSockets (minor — simpler, same UX result, no Redis dependency)
  - Used vanilla JavaScript instead of TypeScript Stimulus controllers (minor — no JS build pipeline exists; inline JS in partial is pragmatic for demo)
  - Chatbot widget implemented as shared partial `_chatbot_widget.html.erb` instead of ViewComponent class (minor — same encapsulation, less boilerplate)
  - Added chatbot to Step 4 (Review & Sign) in addition to Steps 1-3 (enhancement — users often have questions at review)
  - Added quick-suggestion buttons per step for guided interaction (enhancement — improves demo UX)
- **Notes:**
  - LLMService supports both sync (JSON) and streaming (SSE) modes
  - ApplicationContext builds rich system prompt with vehicle details, collected data, jargon definitions, and first-time buyer guidance
  - Chat history (last 20 messages) included in Claude API context for continuity
  - Graceful fallback message if Claude API is unavailable

## Phase 3: OCR Document Scanning — 2026-03-20
- **Status:** Complete
- **Deliverables:** 8/8 complete
- **Deviations:**
  - OcrService supports mock mode (MOCK_OCR=true) with realistic extraction data for demo, plus real AWS Textract integration (minor — plan already anticipated this risk mitigation)
  - Used vanilla JavaScript instead of TypeScript for camera capture controller (minor — consistent with Phase 2 approach)
  - Added separate "Upload" button alongside "Scan" for desktop users who can't use camera (enhancement — better accessibility)
  - Document upload route added at `/document_uploads` instead of nested under `/onboarding/:id/documents` (minor — simpler routing, application_id passed as param)
- **Notes:**
  - Mock OCR returns realistic data: Jane Smith license, Acme Corporation pay stub, State Farm insurance
  - DocumentValidator checks MIME type, file size (50KB-10MB), and document type
  - Auto-populates application_data with extracted fields after successful OCR
  - Checklist dynamically updates with green checkmarks as documents are verified
  - Specific error messages for wrong format, too small, too large, extraction failures

## Phase 4: Emotional Support Layer — 2026-03-20
- **Status:** Complete
- **Deliverables:** 5/5 complete
- **Deviations:**
  - Loan visualizer was already built in Phase 1 step2 view — no changes needed (minor)
  - Session persistence was already functional via OnboardingApplication#current_step + show action redirect (minor — no new code needed)
- **Notes:**
  - Added confidence prompts: step1 (soft credit check info), step2 ("You can adjust these anytime"), step4 ("You're making a great choice" + return policy)
  - Added milestone messages in progress bar: "Pre-qualification done", "Financing locked in", "Documents uploaded", "All done"
  - Added 3-minute inactivity re-engagement in chatbot widget — shows "Still thinking?" prompt
  - Inactivity timer resets on mouse/keyboard/scroll/touch events

## Phase 5: Polish + Deploy — 2026-03-20
- **Status:** Complete (deployment pending push + Render setup)
- **Deliverables:** 5/7 complete (mobile testing and live URL require manual steps)
- **Deviations:**
  - Added Active Storage migration that was missing from Phase 1 (minor — Vehicle model uses `has_many_attached :images` which requires Active Storage tables)
  - Render.com deployment uses `render.yaml` Infrastructure as Code instead of manual dashboard config (minor — more reproducible)
  - Used Procfile with release command for auto-migration and seeding on deploy (enhancement)
- **Notes:**
  - Demo user: demo@carvana.com / demo1234
  - Rails server boots clean on port 3001
  - Seeds create 3 vehicles + demo user
  - README includes full setup instructions, demo walkthrough, and deployment guide
  - Mobile camera testing and live URL deployment are manual steps after push to GitHub
