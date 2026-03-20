# Carvana AI Onboarding Enhancement — Product Requirements Document

> Generated on 2026-03-19

## 1. Product Overview

### Vision
An AI-powered onboarding prototype that demonstrates what Carvana's digital car buying experience could look like with an LLM chatbot, OCR document scanning, and contextual emotional support content layered on top of a multi-step financing flow. Built as a standalone demo for Gauntlet AI's hiring partner program.

### Problem Statement
Carvana users abandon mid-onboarding due to three compounding friction points: complex financial data entry (income verification, credit applications), document upload confusion (wrong doc type, re-request loops), and the emotional stress of committing to a $20–50K purchase decision online with no human escalation path. Internal ops staff compound the problem by receiving incomplete or incorrect submissions, triggering back-and-forth re-request cycles that further erode buyer confidence.

### Target Audience
US consumers buying a vehicle online — particularly first-time car buyers unfamiliar with auto financing terminology, and mobile users completing the flow on a smartphone. Secondary audience is Carvana's internal operations staff who process and flag incomplete applications.

### Value Proposition
Unlike Carvana's current static form flow — which reacts to problems after they occur (document re-requests, post-commitment offer reductions) — this system proactively guides users through each step, auto-fills data from document scans, explains financial terms in plain English, and delivers confidence-building content at the exact moments users are most likely to abandon.

---

## 2. Competitive Landscape

| Product | Approach | Strengths | Weaknesses |
|---------|----------|-----------|------------|
| Carvana | Fully digital, in-house financing (Bridgecrest), soft-pull pre-qual | End-to-end online, no dealership | Title delays (10+ state regulatory actions, $1.5M CT settlement); no human escalation; trade-in bait-and-switch; reactive document re-request loops |
| CarMax | Omnichannel (digital + physical); multi-lender network | Trusted brand, physical fallback | Online-to-in-store handoff kills digital conversion; trade-in appraisal discrepancy |
| Tesla | App-native task list; minimal delivery paperwork | Streamlined, brand-loyal experience | Zero human support; financing rate discrepancy at approval; non-negotiable trade-in reductions on delivery day |
| Vroom / Shift | Pure-play digital, nationwide delivery | Digital-first positioning | Both filed Chapter 11 (2023) — operational execution collapsed at scale |

### Opportunity
All incumbents solve the digital front-end adequately. None solve the **trust and transparency layer** — the gap between what users are shown during browsing and what they experience at commitment. This product fills that gap through proactive AI guidance, document intelligence, and emotional scaffolding at every high-friction step.

---

## 3. Users

| User Type | Description | Primary Goal | Key Pain Points |
|-----------|-------------|--------------|-----------------|
| **Car Buyer** | Consumer buying a vehicle online, $20–50K decision, often on mobile | Complete financing + docs without calling anyone | Complex forms, document re-requests, loan term anxiety |
| **First-Time Buyer** | No prior auto financing experience, unfamiliar with APR, LTV, GAP | Understand what they're signing without feeling overwhelmed | Financial jargon, fear of making the wrong decision |
| **Trade-in Seller** | Trading in existing vehicle as part of purchase (v2) | Fair, transparent offer with no post-commitment surprises | Offer reductions after commitment, unclear inspection criteria |
| **Co-Applicant** | Second person on a financing application (v2) | Complete their portion independently | No dedicated flow, disrupts primary applicant's journey |
| **Ops Staff** | Internal team processing applications, flagging incomplete submissions | Receive complete, correct applications with minimal back-and-forth | Wrong docs, manual review loops, unclear applicant intent |

### User Journeys

#### Car Buyer — Core Purchase Journey
1. **Discovery** — Browses mock inventory, selects vehicle, clicks "Start Purchase"
2. **Pre-Qualification** — Chatbot explains soft pull, guides through income and employment fields
3. **Financing** — Conversational form fill; jargon explained inline; loan visualizer shows payment impact
4. **Documents** — Points camera at license; OCR auto-fills fields; chatbot confirms what was captured
5. **Review & Sign** — Emotional support prompts, Q&A for last-minute questions, confidence confirmation

#### First-Time Buyer — Guided Education Journey
1. **Discovery** — Arrives with no prior financing knowledge
2. **Onboarding** — Experience level detected; enhanced explanation mode activated
3. **Each Step** — "Why we ask this" micro-copy visible; every financial term has plain-English tooltip
4. **Document Step** — Proactive checklist shown before upload: "You'll need: driver's license, one pay stub, proof of insurance"
5. **Outcome** — Completes application understanding what they signed

---

## 4. Functional Requirements

| ID | Domain | Requirement | Priority | User Type | Source |
|----|--------|-------------|----------|-----------|--------|
| FR-01 | Auth | User registration and login | Must-have | All | User |
| FR-02 | Auth | Identity verification via ID scan | Must-have | Car Buyer | User |
| FR-03 | Auth | Session persistence — resume abandoned flow from exact step | Should-have | Car Buyer | Suggested |
| FR-04 | Chatbot | Guided form fill via conversational UI | Must-have | Car Buyer, First-Time Buyer | User |
| FR-05 | Chatbot | Document explainer — what each document is and why it is needed | Must-have | First-Time Buyer | User |
| FR-06 | Chatbot | Live Q&A — financing, delivery, trade-in questions during checkout | Must-have | Car Buyer | User |
| FR-07 | Chatbot | Jargon simplifier — plain English for APR, LTV, GAP insurance, DTI | Must-have | First-Time Buyer | Suggested |
| FR-08 | Chatbot | Drop-off re-engagement — context-aware prompt when user stalls | Should-have | Car Buyer | Suggested |
| FR-09 | Documents | Camera capture for mobile document upload | Must-have | Car Buyer | User |
| FR-10 | Documents | OCR extraction — driver's license auto-fill (name, DOB, address, license number) | Must-have | Car Buyer | User |
| FR-11 | Documents | OCR extraction — pay stubs (employer, income, pay period) | Must-have | Car Buyer | User |
| FR-12 | Documents | OCR extraction — insurance documents (policy number, carrier, coverage dates) | Must-have | Car Buyer | User |
| FR-13 | Documents | Document validation — wrong type, illegible scan, missing fields | Must-have | Car Buyer, Ops Staff | Suggested |
| FR-14 | Documents | Proactive document checklist before upload step begins | Should-have | First-Time Buyer | Suggested |
| FR-15 | Emotional Support | "Why we ask this" micro-copy alongside every sensitive form field | Must-have | First-Time Buyer | User |
| FR-16 | Emotional Support | Loan term visualizer — interactive slider for monthly payment impact | Must-have | Car Buyer | Suggested |
| FR-17 | Emotional Support | Progress indicator with milestone markers | Should-have | Car Buyer | Suggested |
| FR-18 | Emotional Support | Purchase confidence prompts at high-anxiety decision points | Must-have | First-Time Buyer | User |
| FR-19 | Vehicles | Mock vehicle inventory with images (3 seeded cars) | Must-have | Car Buyer | User |
| FR-20 | Vehicles | Vehicle summary card persistent throughout onboarding flow | Must-have | Car Buyer | Suggested |
| FR-21 | Core Flow | Multi-step financing application (5 steps) | Must-have | Car Buyer | User |
| FR-22 | Core Flow | Soft-pull credit pre-qualification simulation | Must-have | Car Buyer | User |
| FR-23 | Core Flow | Pre-fill for returning users | Should-have | Car Buyer | Suggested |
| FR-24 | Ops | Application completeness dashboard | Should-have | Ops Staff | Suggested |
| FR-25 | Ops | Document re-request with specific targeted guidance | Should-have | Ops Staff | Suggested |
| FR-26 | Scheduling | Delivery window / advisor call booking | Could-have | Car Buyer | User |
| FR-27 | Auth | Co-applicant flow | Could-have | Co-Applicant | Suggested |
| FR-28 | Core Flow | Trade-in transparency flow | Could-have | Trade-in Seller | User |

### Priority Summary
- **Must-have:** 16 requirements
- **Should-have:** 7 requirements
- **Could-have:** 3 requirements
- **Won't-have:** 0

### Won't-Have (Explicitly Deferred)

| ID | Requirement | Reason for Deferral |
|----|-------------|---------------------|
| WH-01 | Real Carvana platform integration | No public API — proprietary closed system |
| WH-02 | 360° vehicle viewer | Post-MVP enhancement |
| WH-03 | State-specific DMV compliance rules | Requires legal review per state |
| WH-04 | Native iOS/Android app | Web-first covers mobile; native is v2 |

---

## 5. Non-Functional Requirements

| ID | Category | Requirement | Target | Priority |
|----|----------|-------------|--------|----------|
| NFR-01 | Performance | OCR extraction time after document capture | < 3 seconds | Must-have |
| NFR-02 | Performance | Chatbot response time per reply | < 2 seconds | Must-have |
| NFR-03 | Security | PII encryption (SSN, income, license data) | AES-256 at rest, TLS 1.3 in transit | Must-have |
| NFR-04 | Security | SSN tokenization — never store raw | Tokenized within capture request | Must-have |
| NFR-05 | Compliance | KYC identity verification | NIST 800-63-3 IAL2 | Must-have |
| NFR-06 | Compliance | Federal lending regulations | ECOA, FCRA, TILA, GLBA | Must-have |
| NFR-07 | Compliance | California privacy | CCPA compliant | Must-have |
| NFR-08 | Reliability | Uptime | 99.9% (~8.7 hours downtime/year) | Must-have |
| NFR-09 | Reliability | Session persistence | Resume from exact step after drop-off | Must-have |
| NFR-10 | Data Retention | Document storage lifecycle | 7-year retention, then auto-purge | Must-have |
| NFR-11 | Accessibility | WCAG compliance | 2.1 AA | Should-have |
| NFR-12 | Mobile | Responsive design + camera | Mobile-first, camera access iOS/Android | Must-have |

---

## 6. Platform & Constraints

### Platforms
| Platform | Required | Notes |
|----------|----------|-------|
| Web | Yes | Mobile-first responsive, Chrome/Safari/Firefox/Edge |
| iOS | Yes | Via mobile web — camera access via MediaDevices API |
| Android | Yes | Via mobile web — camera access via MediaDevices API |
| Desktop | Yes | Secondary — wider layout, same app |
| Native App | No | Out of scope for v1 |

### Constraints
- **Tech stack:** Ruby on Rails 7.2, TypeScript, JavaScript — non-negotiable
- **Timeline:** 3-day sprint for demo-ready prototype
- **Scope:** Standalone prototype with mock data — no live Carvana integration
- **LLM:** Anthropic Claude API (claude-sonnet-4-6)
- **OCR:** AWS Textract
- **Storage:** Active Storage (local dev) / AWS S3 (demo deploy)

---

## 7. Success Metrics

| Metric | Target | How to Measure |
|--------|--------|---------------|
| Onboarding completion rate | > 80% of demo sessions complete all 5 steps | Session completion tracking |
| Document scan success rate | > 90% of uploads auto-fill at least one field | OCR extraction logs |
| Chatbot engagement | > 70% of users interact with chatbot at least once | Chat session analytics |
| Drop-off re-engagement | > 50% of stalled sessions resume after prompt | Session resume tracking |
| Ops re-request rate | < 10% of submissions require manual re-request | Document validation pass rate |

---

## 8. Key Decisions

| Decision | Choice | Reasoning |
|----------|--------|-----------|
| LLM provider | Anthropic Claude API (claude-sonnet-4-6) | Best instruction-following, compliance-safe, no financial hallucination |
| OCR provider | AWS Textract | Highest accuracy on financial docs, SOC2 compliant |
| Frontend architecture | Rails + ViewComponent + TypeScript | One codebase — Rails for forms, TypeScript for rich widgets |
| Integration approach | Standalone prototype with mock data | No Carvana public API — demo-grade build appropriate for hiring project |
| Real-time chat | ActionCable (WebSockets) | Built into Rails, no additional infrastructure |
| Scheduling feature | Deferred (Could-have) | Trigger/target ambiguous — needs product decision |
| Data retention | 7 years then auto-purge | Satisfies ECOA minimum (25 months), IRS audit standard (7 years) |
| Uptime target | 99.9% | Standard for financial e-commerce |
| GDPR | Out of scope | US-only — CCPA applies instead |
| Returning user | Session pre-fill variant | Not a separate user type — handled as flow flag |

---

## 9. Open Questions

- Should the chatbot persona have a name/avatar for the demo?
- If this moves to real Carvana integration, what API contracts are available from Bridgecrest and the inventory system?
- What exact trigger defines Intelligent Scheduling — delivery window, financing advisor call, or trade-in inspection?

---

## 10. Next Steps

1. `PROJECT_PLAN.md` generated via `/presearch` — architecture, phases, cost
2. Run `/implement` to execute the 3-day sprint
3. Run `/review` to verify implementation against plan
4. Run `/test-qa` to validate demo flow end-to-end
5. Run `/ship` to deploy demo to Render/Heroku
