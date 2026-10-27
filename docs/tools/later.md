# Tools for later

Each entry says what it does, why it would help us, and when to reconsider. Items marked **scheduled**
were already accepted and have a trigger story; the rest are open options to decide when the need appears.

## Scheduled (accepted, installed with their story)

- **Flipper** — Feature flags with a web UI (enable by user, role or percentage). Lets us ship optional
  modules (Pomodoro, notes, attendance) turned off and test new features only on `test`. Trigger: US-801.
- **Administrate** — Generates an admin panel from the models in plain Rails code that is easy to customize.
  Replaces seeds for editing plans and subjects. Trigger: US-101.
- **PaperTrail** — Keeps a version history of records (who, when, what changed) and can restore them.
  Backbone of "propose a change" and plan audit trails. Trigger: US-114.
- **Pagy** — Very fast, small pagination. Needed for forum, reviews and admin lists. Trigger: first long list.
- **pg_search** — Full-text search on PostgreSQL (accents, typos, ranking) with no external search server.
  Search subjects, teachers, threads. Trigger: US-407.
- **friendly_id** — Readable URLs (`/materias/algebra-1`) instead of numeric ids. Trigger: US-408.
- **ancestry** (or closure_tree) — Tree structure for nested replies in threads. Trigger: US-404.
- **acts_as_votable** — Adds votes to any model (ideas, replies). Trigger: US-402.
- **Rack::Attack** — Throttling and blocklists at the Rack layer: login brute force, post spam. Trigger: US-208, US-412.
- **roo** — Reads Excel/ODS/CSV; for plan imports. Trigger: US-105.
- **pdf-reader** — Extracts text from PDFs; for the SIU Guaraní academic-record import. Trigger: US-601.
  Fragile if the PDF layout changes; keep the parser isolated and heavily tested with sample files.
- **Nokogiri** — HTML/XML parsing (already a Rails dependency); for pasted-HTML imports and public feeds.
- **Faraday** — Flexible HTTP client with retries and middleware, for external APIs (SIU, faculty). Trigger: first API integration.
- **WebMock** — Blocks real HTTP in tests and stubs responses so integrations are tested fast and deterministically. Trigger: with Faraday.
- **icalendar** — Generates `.ics` feeds for Google Calendar/Outlook. Trigger: US-307.
- **web-push** — Browser push notifications (needs HTTPS and a service worker, i.e. PWA). Trigger: US-309.
- **telegram-bot-ruby** — Telegram bot API client for reminders and queries. Trigger: US-608.
- **OmniAuth (Google)** — Social login on top of Devise; can be restricted to the institutional domain. Trigger: US-206.
- **Sentry (free plan)** — Error tracking with stack traces and alerts in production. The free plan is enough
  for a small project; GlitchTip is a self-hosted open-source alternative if limits become a problem. Verify current plan limits.
- **Lograge** — One-line, structured request logs; easier to read in hosting dashboards.
- **Mission Control – Jobs** — Web dashboard for Solid Queue (failed, scheduled, retry). Trigger: first production job.

## Open options (decide when the need appears)

- **Ransack** — Search/filter forms with sortable columns generated from params. Useful for admin lists and the
  reviews filters. Skipped for now: plain scopes plus pg_search cover our needs, and Ransack adds a lot of implicit behavior.
- **Lookbook** — A live catalogue of ViewComponent previews (every card state, every colour). Great for design review once
  there are many components. Trigger: ~10 components or the first designer/helper joining.
- **VCR** — Records real HTTP responses once and replays them in tests. Worth it when an API (SIU) is complex and
  slow to stub by hand. Trigger: SIU API integration.
- **strong_migrations** — Warns about migrations that can lock or break a live database. Trigger: before the first
  production data we cannot lose.
- **annotaterb** — Writes schema comments into models/specs; helps beginners read models. Optional.
- **rack-mini-profiler** — Per-request timing and SQL panel in development; complements Bullet. Optional.
- **PgHero** — Query and index insights for PostgreSQL. Trigger: when `prod` gets real traffic.
- **parallel_tests** — Runs specs in parallel to keep CI fast. Trigger: suite takes more than ~5 minutes.
- **rails-erd** — Generates an entity diagram from models for docs. Optional.
- **Mail provider (Resend, Brevo or similar)** — Transactional email for confirmations and reminders in test/prod. Trigger: US-201.
- **Active Storage + object storage (S3-compatible)** — File uploads for the exam/notes repository and import files. Trigger: US-311 / US-601.
- **Active Record Encryption** — Encrypts sensitive columns (e.g. grades) at rest with Rails built-ins. Consider with the privacy stories.
- **AI moderation (Perspective API or an LLM)** — Classifies toxicity and catches evasion that word lists miss.
  Adds cost, latency and a privacy question; consider after the rule-based filter shows its limits (US-507).
- **CODEOWNERS** — Automatically requests reviewers per path; useful once the team grows.
- **ADR (architecture decision records)** — Short files in `docs/adr/` capturing why we chose each tool.
- **Playwright / Percy** — Browser and visual regression testing if Capybara is not enough.
- **Flipper UI behind admin only** — Remember to protect the Flipper dashboard with the admin role.
