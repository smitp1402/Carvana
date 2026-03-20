class DevDashboardController < ApplicationController
  skip_before_action :authenticate_user!, if: -> { defined?(authenticate_user!) }

  before_action :restrict_to_development

  def index
    @functional_requirements = functional_requirements
    @non_functional_requirements = non_functional_requirements
    @fr_stats = compute_stats(@functional_requirements)
    @nfr_stats = compute_stats(@non_functional_requirements)
  end

  private

  def restrict_to_development
    unless Rails.env.development? || Rails.env.test?
      head :not_found
    end
  end

  def compute_stats(requirements)
    total = requirements.size
    done = requirements.count { |r| r[:status] == :done }
    partial = requirements.count { |r| r[:status] == :partial }
    deferred = requirements.count { |r| r[:status] == :deferred }
    not_started = requirements.count { |r| r[:status] == :not_started }
    percent = total > 0 ? ((done + partial * 0.5) / total.to_f * 100).round(1) : 0
    { total: total, done: done, partial: partial, deferred: deferred, not_started: not_started, percent: percent }
  end

  def functional_requirements
    [
      { id: "FR-01", domain: "Auth", requirement: "User registration and login", priority: "Must-have",
        status: :done, notes: "Devise auth with signup/login/sessions" },
      { id: "FR-02", domain: "Auth", requirement: "Identity verification via ID scan", priority: "Must-have",
        status: :done, notes: "OCR extraction from driver's license" },
      { id: "FR-03", domain: "Auth", requirement: "Session persistence — resume from exact step", priority: "Should-have",
        status: :done, notes: "OnboardingApplication#current_step persists across sessions" },
      { id: "FR-04", domain: "Chatbot", requirement: "Guided form fill via conversational UI", priority: "Must-have",
        status: :done, notes: "Claude API chatbot with step-aware context" },
      { id: "FR-05", domain: "Chatbot", requirement: "Document explainer — what each doc is and why", priority: "Must-have",
        status: :done, notes: "System prompt includes document explanations" },
      { id: "FR-06", domain: "Chatbot", requirement: "Live Q&A — financing, delivery, trade-in questions", priority: "Must-have",
        status: :done, notes: "Free-form Q&A via Claude API" },
      { id: "FR-07", domain: "Chatbot", requirement: "Jargon simplifier — APR, LTV, GAP, DTI", priority: "Must-have",
        status: :done, notes: "Jargon definitions in system prompt + ApplicationContext" },
      { id: "FR-08", domain: "Chatbot", requirement: "Drop-off re-engagement prompt", priority: "Should-have",
        status: :done, notes: "3-minute inactivity detection triggers chatbot prompt" },
      { id: "FR-09", domain: "Documents", requirement: "Camera capture for mobile upload", priority: "Must-have",
        status: :done, notes: "MediaDevices API camera capture + file upload fallback" },
      { id: "FR-10", domain: "Documents", requirement: "OCR extraction — driver's license", priority: "Must-have",
        status: :done, notes: "Mock mode + Textract integration" },
      { id: "FR-11", domain: "Documents", requirement: "OCR extraction — pay stubs", priority: "Must-have",
        status: :done, notes: "Mock mode + Textract integration" },
      { id: "FR-12", domain: "Documents", requirement: "OCR extraction — insurance documents", priority: "Must-have",
        status: :done, notes: "Mock mode + Textract integration" },
      { id: "FR-13", domain: "Documents", requirement: "Document validation (type, legibility, completeness)", priority: "Must-have",
        status: :done, notes: "DocumentValidator checks MIME, size, required fields" },
      { id: "FR-14", domain: "Documents", requirement: "Proactive document checklist", priority: "Should-have",
        status: :done, notes: "Dynamic checklist with green checkmarks on Step 4" },
      { id: "FR-15", domain: "Emotional", requirement: "\"Why we ask this\" micro-copy", priority: "Must-have",
        status: :done, notes: "Tooltips on sensitive form fields" },
      { id: "FR-16", domain: "Emotional", requirement: "Loan term visualizer (interactive slider)", priority: "Must-have",
        status: :done, notes: "Real-time monthly payment calculator on Step 2" },
      { id: "FR-17", domain: "Emotional", requirement: "Progress indicator with milestones", priority: "Should-have",
        status: :done, notes: "Progress bar with milestone messages per step" },
      { id: "FR-18", domain: "Emotional", requirement: "Purchase confidence prompts", priority: "Must-have",
        status: :done, notes: "Confidence prompts at Steps 1, 2, and 4" },
      { id: "FR-19", domain: "Vehicles", requirement: "Mock vehicle inventory (3 seeded cars)", priority: "Must-have",
        status: :done, notes: "Honda Accord, Toyota Camry, Ford Mustang GT" },
      { id: "FR-20", domain: "Vehicles", requirement: "Persistent vehicle summary card", priority: "Must-have",
        status: :done, notes: "Vehicle card visible on all onboarding steps" },
      { id: "FR-21", domain: "Core Flow", requirement: "5-step financing application", priority: "Must-have",
        status: :done, notes: "Steps 1-5 with navigation and state persistence" },
      { id: "FR-22", domain: "Core Flow", requirement: "Soft-pull credit pre-qualification simulation", priority: "Must-have",
        status: :done, notes: "Simulated soft pull on Step 1 pre-qualification" },
      { id: "FR-23", domain: "Core Flow", requirement: "Pre-fill for returning users", priority: "Should-have",
        status: :done, notes: "Application data persisted and pre-filled on revisit" },
      { id: "FR-24", domain: "Ops", requirement: "Application completeness dashboard", priority: "Should-have",
        status: :deferred, notes: "Deferred per MVP scope" },
      { id: "FR-25", domain: "Ops", requirement: "Targeted document re-request with specific guidance", priority: "Should-have",
        status: :deferred, notes: "Deferred per MVP scope" },
      { id: "FR-26", domain: "Scheduling", requirement: "Delivery / advisor call booking", priority: "Could-have",
        status: :deferred, notes: "Deferred per MVP scope" },
      { id: "FR-27", domain: "Auth", requirement: "Co-applicant flow", priority: "Could-have",
        status: :deferred, notes: "Deferred per MVP scope" },
      { id: "FR-28", domain: "Core Flow", requirement: "Trade-in transparency flow", priority: "Could-have",
        status: :deferred, notes: "Deferred per MVP scope" }
    ]
  end

  def non_functional_requirements
    [
      { id: "NFR-01", category: "Performance", requirement: "OCR extraction time", target: "< 3 seconds",
        status: :done, notes: "Mock: instant. Textract: ~2s" },
      { id: "NFR-02", category: "Performance", requirement: "Chatbot response time", target: "< 2 seconds",
        status: :partial, notes: "Needs verification with live Claude API under load" },
      { id: "NFR-03", category: "Security", requirement: "PII encryption at rest", target: "AES-256",
        status: :partial, notes: "Rails encrypted credentials only; no field-level encryption yet" },
      { id: "NFR-04", category: "Security", requirement: "SSN tokenization", target: "Never store raw SSN",
        status: :done, notes: "SSN not collected in current flow" },
      { id: "NFR-05", category: "Compliance", requirement: "KYC identity verification", target: "NIST 800-63-3 IAL2",
        status: :not_started, notes: "Demo prototype — real KYC not implemented" },
      { id: "NFR-06", category: "Compliance", requirement: "Federal lending regulations", target: "ECOA, FCRA, TILA, GLBA",
        status: :not_started, notes: "Demo prototype — compliance audit not performed" },
      { id: "NFR-07", category: "Compliance", requirement: "California privacy", target: "CCPA",
        status: :not_started, notes: "Demo prototype — no CCPA consent flow" },
      { id: "NFR-08", category: "Reliability", requirement: "Uptime", target: "99.9%",
        status: :not_started, notes: "Requires production monitoring (not applicable for demo)" },
      { id: "NFR-09", category: "Reliability", requirement: "Session persistence", target: "Resume from exact step",
        status: :done, notes: "OnboardingApplication#current_step persists" },
      { id: "NFR-10", category: "Data Retention", requirement: "Document lifecycle", target: "7-year retention, auto-purge",
        status: :not_started, notes: "No retention policy implemented (demo scope)" },
      { id: "NFR-11", category: "Accessibility", requirement: "WCAG compliance", target: "2.1 AA",
        status: :partial, notes: "Basic semantic HTML; no full audit performed" },
      { id: "NFR-12", category: "Mobile", requirement: "Responsive + camera", target: "Mobile-first, iOS/Android",
        status: :done, notes: "Tailwind responsive layout; camera capture implemented" }
    ]
  end
end
