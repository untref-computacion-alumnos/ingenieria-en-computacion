# Tools adopted for the skeleton (install on day 1)

Anything not listed here or in [later.md](later.md) needs a team decision first.
Versions: use the latest stable at install time and let Bundler pin them.

## Framework and database

| Tool | Why |
| --- | --- |
| Ruby (latest stable) + Rails 8.x | Convention over configuration; beginner friendly. Generated with `--skip-test` (no Minitest). |
| PostgreSQL | Required database; also powers Solid Queue/Cache/Cable and full-text search later. |
| Solid Queue | Rails 8 default job backend on PostgreSQL, no Redis. |

## Frontend

| Tool | Why |
| --- | --- |
| Hotwire (Turbo + Stimulus) | Interactivity with server-rendered HTML; almost no custom JS. |
| importmap-rails | Rails default, no Node build for JavaScript. |
| tailwindcss-rails | Tailwind without Node. |
| daisyUI | Ready-made Tailwind components and themes (cards, modals, progress, badges). |
| ViewComponent | Testable UI pieces (subject card, grid, progress bar). |

## Accounts and authorization

| Tool | Why |
| --- | --- |
| Devise (+ devise-i18n) | Complete email/password auth, reset, ready for OmniAuth later. |
| Pundit | One policy class per resource; plain Ruby, easy to test. |
| Rolify | Multiple roles per user (student, teacher, moderator, admin). |
| rails-i18n | Spanish (es-AR) translations for dates, errors, pluralization. |

## Testing

| Tool | Why |
| --- | --- |
| rspec-rails | Unit/request/component/policy specs (TDD). |
| cucumber-rails + cucumber | Gherkin acceptance features in English (BDD). |
| capybara + cuprite | Drives the app in a headless Chrome without chromedriver; works inside Docker. |
| factory_bot_rails | Readable test data. |
| faker | Realistic incidental values for tests and dev seeds. |
| shoulda-matchers | One-line validation/association specs. |
| pundit-matchers | Policy specs. |
| simplecov | Coverage; floor of 90 % in CI. |
| database_cleaner-active_record | Clean DB for JS scenarios where transactions are not shared. |

## Quality, linters and security

| Tool | Checks | Notes |
| --- | --- | --- |
| RuboCop + rubocop-rails, rubocop-rspec, rubocop-performance, rubocop-capybara, rubocop-factory_bot | Ruby style | Default rules (not Omakase); relax metrics in `.rubocop.yml` while learning |
| erb_lint | `.erb` views | Complements RuboCop |
| markdownlint-cli2 | `.md` | Run via npm in the dev image |
| yamllint | `.yml` | Workflows, I18n, seeds; installed from the OS package |
| cuke_linter | `.feature` | Ruby gem, no Node needed (preferred over the npm gherkin-lint) |
| i18n-tasks | Missing/unused I18n keys | Fails CI on missing keys, supports "no hard-coded text" |
| Brakeman | Rails vulnerabilities | CI job `security` |
| bundler-audit | Vulnerable gems | CI job `security` |
| Bullet | N+1 queries | Raises in test, warns in dev |
| Reek + rails_best_practices | Code smells | Advisory at first (non-blocking); make blocking when the code base is clean |
| commitlint (`@commitlint/cli`) | Commit message format | Rules in `.commitlintrc.yml`; run by Lefthook `commit-msg` and by CI on pull requests; installed with npm |
| Lefthook | Git hooks (run on the host) | pre-commit: author name + linters on the whole project; prepare-commit-msg: pre-fills `(us-NN):` from the branch; commit-msg: commitlint; pre-push: `bin/ci` |
| Dependabot | Dependency updates | `.github/dependabot.yml` for bundler, GitHub Actions and npm |

## Development environment

| Tool | Why |
| --- | --- |
| Docker + Docker Compose | `docker compose up` runs the app, PostgreSQL and Mailpit identically on every OS. |
| Mailpit | Catches development emails (password reset) with a web UI. |
| `.ruby-version` | Read by rbenv, asdf, mise and rvm, so local (non-Docker) use works on any OS. |
| Local toolchain option | Recommended: **mise** (Linux/macOS, Windows via WSL2). rbenv/asdf also work with `.ruby-version`. |
| `.editorconfig` | Same whitespace and line endings in every editor. |
| `bin/dc`, `bin/ci` | `bin/dc` runs any command in the container or natively (`LOCAL=1`); `bin/ci` runs all gates through `bin/lint`, `bin/security`, `bin/advisory` and `bin/test`, which can also be run alone. |

## Scheduled with their first story (adopted, not installed on day 1)

These were accepted; the trigger story installs them. Descriptions in [later.md](later.md).

| Tool | Trigger |
| --- | --- |
| Flipper (+ flipper-active_record, flipper-ui) | US-801 optional modules (or earlier if a feature needs a flag) |
| Administrate | US-101 admin area |
| PaperTrail | US-114 change proposals / history |
| Pagy, pg_search | First long list or search (US-407 / plan lists) |
| friendly_id, ancestry, acts_as_votable | Community (US-401…408) |
| Rack::Attack | US-208 / US-412 |
| roo, pdf-reader, Nokogiri, Faraday, WebMock | US-105 CSV/Excel import; US-601 SIU file import; first HTTP integration |
| icalendar, web-push, telegram-bot-ruby | US-307, US-309, US-608 |
| Sentry (free plan) + Lograge | First deploy to `prod` (US-001 for `test` if desired) |
| Mission Control Jobs | First background job in production |
| OmniAuth Google | US-206 |
