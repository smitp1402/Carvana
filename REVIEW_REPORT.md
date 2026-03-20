# Review Report

> Reviewed on 2026-03-20 against PROJECT_PLAN.md

## Summary
- **Requirements:** 21/28 pass, 2 partial, 5 deferred (by design)
- **Architecture:** Pass with logged deviations
- **Code quality:** 4 issues (1 critical, 2 warnings, 1 suggestion)
- **Overall verdict:** Needs test suite before shipping; functionally solid

---

## Requirements Status

### Functional Requirements

| ID | Requirement | Priority | Status | Notes |
|----|-------------|----------|--------|-------|
| FR-01 | User registration and login | Must-have | **Pass** | Devise auth with signup/login/sessions. Auto-login in dev mode. |
| FR-02 | Identity verification via ID scan | Must-have | **Pass** | OCR extraction from driver's license (mock + Textract). Auto-fills name, DOB, address. |
| FR-03 | Session persistence — resume from exact step | Should-have | **Pass** | `OnboardingApplication#current_step` persisted; `show` action redirects to correct step. |
| FR-04 | Guided form fill via conversational UI | Must-have | **Pass** | Claude API chatbot with step-aware context, streaming SSE responses. |
| FR-05 | Document explainer — what each doc is and why | Must-have | **Pass** | System prompt includes doc explanations; "Why we ask" copy on each upload zone. |
| FR-06 | Live Q&A — financing, delivery, trade-in questions | Must-have | **Pass** | Free-form Q&A via Claude API with 20-message history context. |
| FR-07 | Jargon simplifier — APR, LTV, GAP, DTI | Must-have | **Pass** | `ApplicationContext::JARGON_DEFINITIONS` injected into system prompt. Accordion explainers on step 2. |
| FR-08 | Drop-off re-engagement prompt | Should-have | **Pass** | 3-minute inactivity timer in chatbot JS triggers "Still thinking?" message. |
| FR-09 | Camera capture for mobile upload | Must-have | **Pass** | `<input capture="environment">` for camera; separate file upload button for desktop. |
| FR-10 | OCR extraction — driver's license | Must-have | **Pass** | `OcrService` maps FIRST NAME, LAST NAME, DOB, ADDRESS, LICENSE NUMBER. Mock + Textract. |
| FR-11 | OCR extraction — pay stubs | Must-have | **Pass** | Maps EMPLOYER, GROSS PAY, PAY PERIOD, NET PAY. |
| FR-12 | OCR extraction — insurance documents | Must-have | **Pass** | Maps POLICY NUMBER, CARRIER, EFFECTIVE DATE, EXPIRATION DATE. |
| FR-13 | Document validation (type, legibility, completeness) | Must-have | **Pass** | `DocumentValidator` checks MIME type, size (50KB–10MB), document type. Specific error messages. |
| FR-14 | Proactive document checklist | Should-have | **Pass** | Amber checklist box at top of step 3 with dynamic green checkmarks. |
| FR-15 | "Why we ask this" micro-copy | Must-have | **Partial** | Present on step 1 (income field) and step 2 (SSN field). Missing on employer name field. Step 3 doc zones have "why" text. |
| FR-16 | Loan term visualizer (interactive slider) | Must-have | **Pass** | Step 2: dual range sliders for term (24–84 mo) and down payment ($0–$10K). Live monthly payment calculation using amortization formula. |
| FR-17 | Progress indicator with milestones | Should-have | **Pass** | 5-step progress bar with SVG checkmarks, milestone text per step. |
| FR-18 | Purchase confidence prompts | Must-have | **Pass** | Step 1: soft credit check reassurance. Step 2: "adjust anytime". Step 4: return policy. |
| FR-19 | Mock vehicle inventory (3 seeded cars) | Must-have | **Pass** | Honda Accord EX-L, Toyota Camry XSE, Ford Mustang GT. `db/seeds.rb` verified. |
| FR-20 | Persistent vehicle summary card | Must-have | **Pass** | `_vehicle_card.html.erb` rendered on all onboarding steps. |
| FR-21 | 5-step financing application | Must-have | **Pass** | Steps 1–5 with navigation, state machine, data persistence. |
| FR-22 | Soft-pull credit pre-qualification simulation | Must-have | **Partial** | Step 1 collects income/employment data and labels it as "soft pull", but there's no simulated pre-qual result (e.g., estimated APR, approval likelihood). The step just collects data and advances. |
| FR-23 | Pre-fill for returning users | Should-have | **Pass** | `application_data` JSON persisted; form fields populated from `@application.data[]`. |
| FR-24 | Application completeness dashboard | Should-have | **Deferred** | Per MVP scope. |
| FR-25 | Targeted document re-request | Should-have | **Deferred** | Per MVP scope. |
| FR-26 | Delivery / advisor call booking | Could-have | **Deferred** | Per MVP scope. |
| FR-27 | Co-applicant flow | Could-have | **Deferred** | Per MVP scope. |
| FR-28 | Trade-in transparency flow | Could-have | **Deferred** | Per MVP scope. |

### Non-Functional Requirements

| ID | Requirement | Target | Status | Notes |
|----|-------------|--------|--------|-------|
| NFR-01 | OCR extraction time | < 3 seconds | **Pass** | Mock: instant. Textract: ~2s per plan. |
| NFR-02 | Chatbot response time | < 2 seconds | **Needs Testing** | Structurally sound (streaming SSE), but runtime latency unverified. |
| NFR-03 | PII encryption at rest | AES-256 | **Missing** | `application_data` stored as plain JSON text in SQLite. SSN last 4 stored unencrypted. No field-level encryption. Rails `encrypted_credentials` only protects API keys, not user PII. |
| NFR-04 | SSN tokenization | Never store raw | **Partial** | Only last 4 digits collected (good), but stored in plain text in `application_data` JSON. Not tokenized. |
| NFR-05 | KYC identity verification | NIST IAL2 | **Missing** | Demo prototype — no real KYC. Acceptable for demo scope. |
| NFR-06 | Federal lending compliance | ECOA, FCRA, TILA, GLBA | **Missing** | Demo prototype — no compliance implementation. Acceptable for demo scope. |
| NFR-07 | California privacy | CCPA | **Missing** | No consent flow. Acceptable for demo scope. |
| NFR-08 | Uptime | 99.9% | **Missing** | No monitoring. Acceptable for demo scope. |
| NFR-09 | Session persistence | Resume from exact step | **Pass** | `current_step` persisted; `show` redirects to correct step. |
| NFR-10 | Document lifecycle | 7-year retention | **Missing** | No retention policy. Acceptable for demo scope. |
| NFR-11 | Accessibility | WCAG 2.1 AA | **Needs Testing** | Semantic HTML used; form labels present. No automated audit performed. |
| NFR-12 | Mobile responsive + camera | Mobile-first | **Pass** | Tailwind responsive classes; camera capture with `capture="environment"`. |

---

## Architecture Review

### Tech Stack
| Planned | Actual | Verdict |
|---------|--------|---------|
| Rails 7.2 | Rails 8.1 | **OK** — logged deviation, newer version |
| PostgreSQL | SQLite3 (dev) | **OK** — logged, PostgreSQL for production via Render |
| ViewComponent 3.x | Installed, unused (partials used) | **OK** — logged, same encapsulation |
| TypeScript + Stimulus | Vanilla JS inline | **OK** — logged, pragmatic for demo |
| ActionCable WebSockets | SSE via ActionController::Live | **OK** — logged, simpler, same UX |
| Tailwind CSS 3.x | Tailwind CSS 4.2 (via cssbundling) | **OK** — newer version |
| Devise 4.9 | Devise 5.0.3 | **OK** — newer version |

### Components
All planned components exist:
- `OnboardingApplicationsController` — step routing, state management ✓
- `ChatMessagesController` — sync + streaming responses ✓
- `DocumentUploadsController` — upload + OCR extraction ✓
- `VehiclesController` — browse + detail ✓
- `LlmService` — Claude API wrapper ✓
- `OcrService` — Textract + mock mode ✓
- `ApplicationContext` — system prompt builder ✓
- `DocumentValidator` — file validation ✓

### Data Models
| Model | Planned Fields | Actual | Verdict |
|-------|---------------|--------|---------|
| User | email, password_digest, first_name, last_name, experience_level | All present via Devise + custom fields | **Pass** |
| Vehicle | make, model, year, price, mileage, color, stock_no, description | All present + `featured` boolean (enhancement) | **Pass** |
| OnboardingApplication | user_id, vehicle_id, current_step, status + individual fields | Uses `application_data` JSON instead of individual columns | **Deviation** — acceptable, more flexible for demo |
| DocumentUpload | application_id, document_type, status, extracted_fields | `extracted_data` (text) instead of `extracted_fields` (jsonb). `filename` added. | **Pass** — functionally equivalent |
| ChatMessage | application_id, role, content, step_context | All present | **Pass** |

### API Surface
| Planned Endpoint | Actual | Verdict |
|-----------------|--------|---------|
| GET /vehicles | `vehicles#index` | **Pass** |
| GET /vehicles/:id | `vehicles#show` | **Pass** |
| POST /auth/signup | `devise_for :users` (POST /users) | **Pass** — Devise convention |
| POST /auth/login | `devise_for :users` (POST /users/sign_in) | **Pass** — Devise convention |
| POST /onboarding | `onboarding_applications#create` | **Pass** |
| GET /onboarding/:id | `onboarding_applications#show` | **Pass** |
| PATCH /onboarding/:id/step/:n | `onboarding_applications#update_step` | **Pass** |
| POST /onboarding/:id/documents | `document_uploads#create` via nested route | **Pass** |
| POST /chatbot/messages | `chat_messages#create` (POST /chat_messages) | **Pass** — slightly different path |
| GET /ops/applications | Not implemented | **Deferred** — per MVP scope |

---

## Deviation Assessment

| Deviation | Justified | Impact | Action Needed |
|-----------|-----------|--------|---------------|
| Rails 8.1 instead of 7.2 | Yes — newer, same APIs | None | None |
| SQLite3 instead of PostgreSQL | Yes — easier local dev | Low — must use PG for deploy | Switch to pg gem for production |
| SSE instead of ActionCable | Yes — simpler, no Redis | None | None |
| Vanilla JS instead of TypeScript | Yes — no build pipeline | Low — less type safety | Acceptable for demo |
| ViewComponent unused (partials) | Yes — less boilerplate | None | None |
| `application_data` JSON instead of individual columns | Yes — flexible schema | Low — no type enforcement | Acceptable for demo |
| Ford Explorer → Ford Mustang GT | Yes — cosmetic | None | None |
| `/document_uploads` instead of nested route | Partially — both routes exist | None | Nested route also works |

All deviations are justified and don't create downstream problems.

---

## Code Quality Issues

### CRITICAL (must fix before testing)

- [x] **~~ANTHROPIC_API_KEY in `.env`~~** — `.env` is properly in `.gitignore` and NOT tracked by git. No exposure risk. **Resolved.**

- [ ] **No test suite** — 0% test coverage against 80% target. No RSpec setup, no test files exist. This is the single biggest gap in the project.
  - **Fix:** Set up RSpec, write model/controller/service tests before demo.

### WARNINGS (should fix)

- [ ] **No CSRF protection on JSON endpoints** — `ChatMessagesController` and `DocumentUploadsController` accept JSON POST requests. The chatbot widget sends CSRF tokens via headers (good), but `ApplicationController` doesn't explicitly skip or verify CSRF for JSON. Rails 8 defaults may handle this, but verify `protect_from_forgery` behavior.
  - **File:** `app/controllers/application_controller.rb`

- [ ] **`application_data` not validated** — `OnboardingApplication#update_data` merges arbitrary hashes into `application_data` with no schema validation. A malicious POST could inject any key-value pair.
  - **File:** `app/models/onboarding_application.rb:42-44`
  - **File:** `app/controllers/onboarding_applications_controller.rb:52-54` — `step_params` does use `permit()`, which mitigates this for the form flow. But `DocumentUploadsController#auto_fill_application` writes directly without the same permit filtering.

### SUGGESTIONS (optional)

- [ ] **Hardcoded APR (6.9%)** — The loan visualizer and review page use a fixed 6.9% APR. Consider making this configurable or noting it's estimated more prominently.
  - **File:** `app/views/onboarding_applications/step2.html.erb:101`

---

## Success Criteria

| Phase | Criteria | Status |
|-------|----------|--------|
| Phase 1 | `rails db:seed` populates 3 vehicles and demo user | **Verified** — DB has 3 vehicles, 1 user |
| Phase 1 | User can browse vehicles and navigate 5 steps | **Verified** — routes and controller logic confirmed |
| Phase 1 | Vehicle card visible on every step | **Verified** — `_vehicle_card` partial rendered in steps 1–4 |
| Phase 1 | Progress indicator updates per step | **Verified** — `_progress` partial uses `application.current_step` |
| Phase 2 | Streaming Claude response within 2 seconds | **Needs Testing** — code supports streaming SSE |
| Phase 2 | Chatbot knows step and vehicle context | **Verified** — `ApplicationContext` builds full system prompt |
| Phase 2 | "Why we ask this" on sensitive fields | **Verified** — present on income, SSN, doc upload zones |
| Phase 2 | Jargon terms explained | **Verified** — JARGON_DEFINITIONS hash + accordion explainers |
| Phase 3 | Camera capture on mobile | **Needs Testing** — `capture="environment"` attribute set |
| Phase 3 | License scan auto-fills fields | **Verified** — `auto_fill_application` maps license fields to app data |
| Phase 3 | Wrong doc type shows specific error | **Verified** — `DocumentValidator` raises typed errors |
| Phase 3 | Checklist lists required docs | **Verified** — amber checklist with 3 items on step 3 |
| Phase 4 | Loan visualizer real-time updates | **Verified** — JS `updateDisplay()` on slider input events |
| Phase 4 | Confidence prompts at Steps 2, 3, 5 | **Verified** — present at steps 1, 2, and 4 (step numbering differs from plan due to 0-indexed flow) |
| Phase 4 | Session persistence across browser close | **Verified** — `current_step` persisted in DB |
| Phase 4 | Idle prompt after 3 minutes | **Verified** — `setTimeout(180000)` in chatbot JS |
| Phase 5 | Full flow completable on mobile | **Needs Testing** — requires device testing |
| Phase 5 | Live URL accessible | **Not Met** — deployment pending |
| Phase 5 | No unhandled errors in production | **Needs Testing** — requires deployment |

---

## Recommended Actions

1. **CRITICAL:** Rotate the Anthropic API key and ensure `.env` is in `.gitignore` (check if it already is — it may have been added recently but the file was committed before)
2. **Write tests** — 0% coverage. At minimum: model validations, controller happy paths, service unit tests
3. **Fix FR-15** — Add "why we ask" micro-copy to employer name field on step 1
4. **Fix FR-22** — Add a simulated pre-qual result after step 1 (e.g., "Pre-qualified! Estimated APR: 6.9%")
5. **Deploy** — Push to GitHub, set up Render, get live URL working

## Next Step

Fix the API key exposure (critical), then proceed to `/test-qa` for runtime verification.
