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
