# Skeleton setup guide

Goal: from this empty repository to a working Rails app with Docker, tests, linters, CI and protected
branches, ready to start [US-001](user-stories/mvp/US-001-walking-skeleton.md). Do these steps in one
sitting, pairing if possible. Commands assume Linux/macOS (or WSL2 on Windows).

Versions below are placeholders (`3.4`, `17`); use the latest stable at the time and keep `.ruby-version`,
`Dockerfile.dev` and the CI workflow in sync. Snippets are starting points; where a tool's file format may
have changed, the tool's own docs win.

## 0. Prerequisites

- Git, a GitHub account with an empty repository for the project, Docker with Compose v2.
- Optional for native (non-Docker) work: **mise** (or rbenv/asdf) with Ruby, PostgreSQL client libs, Node LTS.
- Editor: VS Code or Zed (shared settings added in step 5).

## 1. Repository

```bash
cd ingenieria-en-computacion
git init -b main
git remote add origin git@github.com:<org>/<repo>.git
```

Keep `CLAUDE.md` and `docs/` (already here). Do **not** create a root `README.md` yet (Rails would ask to overwrite it).

## 2. Generate the Rails app (no local Ruby needed)

```bash
docker run --rm -v "$PWD":/app -w /app ruby:3.4 bash -c \
  "gem install rails --no-document && rails new . --database=postgresql --css=tailwind \
   --skip-test --skip-rubocop --skip-ci --skip-kamal --skip-jbuilder --force"
sudo chown -R "$USER":"$USER" .
echo "3.4" > .ruby-version        # must match the Ruby of the image; check with: ruby -v
```

`--skip-test` removes Minitest. We skip Rails' RuboCop-Omakase and CI template because we use our own.
Kamal is not used.

## 3. Docker development environment

`Dockerfile.dev`:

```dockerfile
ARG RUBY_VERSION=3.4
FROM ruby:${RUBY_VERSION}-slim
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential git curl libpq-dev libyaml-dev pkg-config \
      postgresql-client chromium yamllint nodejs npm \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g markdownlint-cli2
WORKDIR /rails
COPY Gemfile Gemfile.lock ./
RUN bundle install
```

`compose.yml` (if Rails generated a compose file, merge instead):

```yaml
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: postgres
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 5s
      retries: 10

  mailpit:
    image: axllent/mailpit
    ports:
      - "8025:8025"   # web UI for caught emails

  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    command: sh -c "bundle check || bundle install; bin/rails db:prepare; bin/dev"
    ports:
      - "3000:3000"
    environment:
      DB_HOST: db
      DB_USER: postgres
      DB_PASSWORD: postgres
      SMTP_HOST: mailpit
      BINDING: 0.0.0.0
    volumes:
      - .:/rails
      - bundle:/usr/local/bundle
    depends_on:
      db:
        condition: service_healthy

volumes:
  pgdata:
  bundle:
```

In `config/database.yml`, make the connection configurable so Docker and native setups both work:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  host: <%= ENV.fetch("DB_HOST", "localhost") %>
  username: <%= ENV.fetch("DB_USER", "postgres") %>
  password: <%= ENV.fetch("DB_PASSWORD", "postgres") %>
  # keep the pool/max_connections line that Rails generated
```

Development mail goes to Mailpit: in `config/environments/development.rb`

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { address: ENV.fetch("SMTP_HOST", "localhost"), port: 1025 }
```

`bin/dc` (executable) runs any command in the container, or natively with `LOCAL=1`:

```bash
#!/usr/bin/env bash
if [ -f /.dockerenv ] || [ "${LOCAL:-0}" = "1" ]; then exec "$@"; fi
if docker compose ps --status running --services 2>/dev/null | grep -qx web; then
  exec docker compose exec -T web "$@"
fi
exec docker compose run --rm -T web "$@"
```

Start it: `docker compose up --build` → <http://localhost:3000> (Rails welcome page), <http://localhost:8025> (Mailpit).

## 4. Gems

Remove nothing Rails generated except what the notes say; add to the `Gemfile`:

```ruby
gem "view_component"
gem "devise"
gem "devise-i18n"
gem "rails-i18n"
gem "pundit"
gem "rolify"

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "bullet"
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "erb_lint", require: false
  gem "reek", require: false
  gem "rails_best_practices", require: false
  gem "i18n-tasks", require: false
  gem "lefthook", require: false
end

group :test do
  gem "cucumber-rails", require: false
  gem "cuke_linter", require: false
  gem "capybara"
  gem "cuprite"
  gem "shoulda-matchers"
  gem "pundit-matchers"
  gem "simplecov", require: false
  gem "database_cleaner-active_record"
end
```

Then `docker compose run --rm web bundle install`. Remove any `rubocop-rails-omakase` line if present.

## 5. Install and configure

```bash
bin/dc bin/rails generate rspec:install
bin/dc bin/rails generate cucumber:install
bin/dc bin/rails generate devise:install
bin/dc bin/rails generate devise User
bin/dc bin/rails generate pundit:install
bin/dc bin/rails generate rolify Role User
bin/dc bin/rails db:migrate
```

- **Devise + Turbo**: in `config/initializers/devise.rb` set `config.responder.error_status = :unprocessable_entity`
  and `config.responder.redirect_status = :see_other`.
- **I18n** (`config/application.rb`): `config.i18n.default_locale = :"es-AR"`, `config.i18n.fallbacks = [:es]`;
  copy the i18n-tasks template: `bin/dc bundle exec i18n-tasks` prints how (`config/i18n-tasks.yml`).
- **daisyUI** (Tailwind 4 setup of `tailwindcss-rails`): download the daisyUI plugin files into
  `app/assets/vendor/` as described on daisyUI's Rails install page and register them with
  `@plugin "../vendor/daisyui.js";` in `app/assets/tailwind/application.css`. Check that page for current paths.
- **Capybara + Cuprite**, in `spec/support/cuprite.rb` and `features/support/cuprite.rb`:

```ruby
require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  options = File.exist?("/.dockerenv") || ENV["CI"] ? { "no-sandbox" => nil } : {}
  Capybara::Cuprite::Driver.new(app, window_size: [1280, 800], browser_options: options)
end
Capybara.javascript_driver = :cuprite
```

  If Chrome is not found, set `BROWSER_PATH=/usr/bin/chromium`.

- **Shoulda Matchers / FactoryBot** in `spec/rails_helper.rb`: configure `Shoulda::Matchers` with `with.test_framework :rspec`, `with.library :rails`; add `config.include FactoryBot::Syntax::Methods`.
- **SimpleCov** at the very top of `spec/spec_helper.rb` and `features/support/env.rb`:

```ruby
require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
  use_merging true
  command_name "rspec"        # use "cucumber" in the Cucumber file
end
```

- **Bullet** in `config/environments/development.rb` (`Bullet.enable = true; Bullet.rails_logger = true`) and
  `test.rb` (`Bullet.enable = true; Bullet.raise = true`).
- **Cucumber layout**: `features/<epic>/*.feature`, `features/step_definitions/`, `features/support/`.
  Tag stories with `@US-XXX`. JS scenarios use `@javascript`.
- **Editor settings**: `.editorconfig` (UTF-8, LF, 2 spaces for Ruby/YAML/ERB/JS, trim trailing whitespace).

## 6. Linters, hooks and one command to check everything

`.rubocop.yml`:

```yaml
plugins:
  - rubocop-rails
  - rubocop-rspec
  - rubocop-performance
  - rubocop-capybara
  - rubocop-factory_bot
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.4
  Exclude: ["db/schema.rb", "bin/**/*", "vendor/**/*", "node_modules/**/*"]
Style/Documentation:
  Enabled: false
Metrics/BlockLength:
  Exclude: ["spec/**/*", "features/**/*", "config/**/*"]
```

(Older RuboCop versions use `require:` instead of `plugins:`.) Relax `Metrics/*` if they get in the way
while the team learns; tighten later. `.erb_lint.yml`: `EnableDefaultLinters: true`.
`.markdownlint-cli2.yaml`:

```yaml
config:
  MD013: false      # line length
  MD024:
    siblings_only: true
globs: ["**/*.md"]
ignores: ["node_modules/**", "vendor/**", "coverage/**"]
```

`.yamllint`:

```yaml
extends: default
rules:
  line-length: disable
  document-start: disable
  truthy:
    check-keys: false     # GitHub Actions uses `on:`
ignore: |
  node_modules/
  vendor/
```

`lefthook.yml`:

```yaml
pre-commit:
  parallel: true
  commands:
    author-name:
      run: git config user.name | grep -Eq '^[^ ]+( [^ ]+)+$' || (echo "git user.name must be your full name (first and last name)" && exit 1)
    rubocop:
      glob: "*.rb"
      run: bundle exec rubocop
    erb_lint:
      glob: "*.erb"
      run: bundle exec erb_lint --lint-all
    markdownlint:
      glob: "*.md"
      run: markdownlint-cli2
    yamllint:
      glob: "*.{yml,yaml}"
      run: yamllint .
    cuke_linter:
      glob: "*.feature"
      run: bundle exec cuke_linter
prepare-commit-msg:
  commands:
    story-scope:
      run: |
        set -- {0}
        [ $# -gt 1 ] && exit 0
        branch=$(git symbolic-ref --short HEAD 2>/dev/null) || exit 0
        story=$(echo "$branch" | tr 'A-Z' 'a-z' | sed -nE 's/^(us-[0-9]+).*/\1/p')
        [ -z "$story" ] && exit 0
        [ -n "$(head -n 1 {1})" ] && exit 0
        { printf '(%s): \n' "$story"; tail -n +2 {1}; } > {1}.new && mv {1}.new {1}
commit-msg:
  commands:
    commitlint:
      run: commitlint --edit {1}
pre-push:
  commands:
    ci:
      run: bin/ci
```

Install hooks: `bundle exec lefthook install` (run on the host so the hooks live in `.git/`; they run locally, not in the container).

`bin/ci` runs the same set as CI through four scripts that can also be run alone: `bin/lint` (RuboCop, erb_lint,
markdownlint, yamllint, cuke_linter, i18n-tasks), `bin/security` (Brakeman, bundler-audit, importmap audit),
`bin/advisory` (Reek, rails_best_practices; never fail) and `bin/test` (RSpec, Cucumber, coverage gate).
`config/ci.rb` lists the steps:

```ruby
CI.run do
  step "Setup", "bin/setup --skip-server"
  step "Lint", "bin/lint"
  step "Security", "bin/security"
  step "Advisory", "bin/advisory"
  step "Test", "bin/test"
end
```

`bin/coverage-check` (executable Ruby) enforces the 90 % floor on the merged result; confirm the
`coverage/.last_run.json` keys with the SimpleCov version you installed:

```ruby
#!/usr/bin/env ruby
require "json"
minimum = Float(ENV.fetch("COVERAGE_MIN", "90"))
percent = JSON.parse(File.read("coverage/.last_run.json")).dig("result", "line")
abort "Coverage #{percent}% is below #{minimum}%" if percent < minimum
puts "Coverage #{percent}% OK"
```

Run `bin/dc bin/ci` once; fix what the generated app trips (usually a handful of offenses). Commit the baseline.

## 7. CI (GitHub Actions)

`.github/workflows/ci.yml` — job names are the **required checks** in step 9:

```yaml
name: CI
on:
  pull_request:
    branches: [main, test, prod]
  push:
    branches: [main]
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
permissions:
  contents: read

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with: { bundler-cache: true }
      - uses: actions/setup-node@v4
        with: { node-version: lts/* }
      - run: npm install -g markdownlint-cli2
      - run: pip install yamllint
      - run: bundle exec rubocop
      - run: bundle exec erb_lint --lint-all
      - run: markdownlint-cli2
      - run: yamllint .
      - run: bundle exec cuke_linter
      - run: bundle exec i18n-tasks health
      - run: bundle exec reek || true
      - run: bundle exec rails_best_practices . || true

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with: { bundler-cache: true }
      - run: bundle exec brakeman -q --no-pager
      - run: bundle exec bundler-audit check --update

  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:17
        env: { POSTGRES_PASSWORD: postgres }
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready --health-interval 10s
          --health-timeout 5s --health-retries 5
    env:
      RAILS_ENV: test
      CI: "true"
      DB_HOST: localhost
      DB_USER: postgres
      DB_PASSWORD: postgres
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with: { bundler-cache: true }
      - run: bin/rails db:prepare
      - run: bin/rails tailwindcss:build
      - run: bundle exec rspec
      - run: bundle exec cucumber
      - run: bin/coverage-check
      - uses: actions/upload-artifact@v4
        if: always()
        with: { name: coverage, path: coverage }
```

## 8. Repository files

- `.github/pull_request_template.md` — the checklist from [definition-of-done.md](process/definition-of-done.md).
- `.github/dependabot.yml` — weekly updates for `bundler` and `github-actions` (Rails may have generated one).
- Root `README.md` — what the project is, `docker compose up`, `bin/dc bin/ci`, links to `docs/` and `CLAUDE.md`.
- `.gitignore` additions: `coverage/`, `.env*` (secrets never in git; use Rails credentials and GitHub secrets).

## 9. GitHub: branches, protection and board

```bash
git add -A && git commit -m "chore(us-001): Rails skeleton, tooling and docs"
git branch test && git branch prod
git push -u origin main test prod

gh repo edit --enable-merge-commit --enable-squash-merge=false --enable-rebase-merge=false \
  --delete-branch-on-merge
```

Then in **Settings → Rules → Rulesets** create one ruleset targeting `main`, `test` and `prod`:

- Restrict deletions and block force pushes.
- Require a pull request before merging: **1 approval**, dismiss stale approvals, require conversation resolution,
  allowed merge methods: **merge commit only**.
- Require status checks: `lint`, `security`, `test`.
- Bypass list: empty. (Initially the first push above is allowed because the branches exist before the ruleset; enable it right after.)

Create the **GitHub Project** (board): columns `Backlog`, `Ready`, `In progress`, `In review`, `Done`; add the MVP
stories from [user-stories/](user-stories/README.md) as issues (title `US-XXX …`, body = story file, label per epic)
in the listed order. Set the WIP rule: only one issue in `In progress`.

## 10. Hosting options (free first)

Pick one for `test` and `prod` while doing US-001. These facts are from memory and **change often**; verify current free-tier
limits before committing.

| Option | Idea | Trade-off |
| --- | --- | --- |
| Render (free web service) + external free PostgreSQL such as Neon | Easiest PaaS; deploys from the `test`/`prod` branches | Free web services sleep when idle (slow first request); free databases on the same provider have expired in the past, so prefer an external one |
| Fly.io / Railway | Good Docker/Rails support | Free usage is limited or trial-based; may need a card |
| Own VPS or an "always free" cloud VM | Full control, stable, cheap | You operate the server (updates, backups, TLS) |
| Faculty server | Free and institutional | Depends on the faculty's approval and constraints |

Suggested path: `test` on the free option (sleeping is fine), `prod` on the same stack until real users arrive, then move
`prod` to a cheap always-on plan or VPS (a few USD a month). In both cases:

- Add GitHub Environments `test` and `prod` with secrets (`RAILS_MASTER_KEY`, `DATABASE_URL`, deploy token).
- Deploy workflow triggers on `push` to `test` / `prod` (after the PR merge) and runs the platform's deploy command.
- Rails 8's production config puts Solid Queue/Cache/Cable in separate databases; on hosts offering one database,
  point them at the primary database, or run jobs inside Puma with `SOLID_QUEUE_IN_PUMA=true` on a single small instance.
- Add Sentry and Lograge with the first `prod` deploy (see [tools/now.md](tools/now.md)).
- Record the decision in `CLAUDE.md`.

## 11. Done when…

- [ ] `docker compose up` serves the app on port 3000 and Mailpit on 8025 from a clean clone.
- [ ] `bin/dc bin/ci` passes locally; the same commands pass in CI on a test PR.
- [ ] `main`, `test`, `prod` exist, are protected, and merge commits are the only allowed method.
- [ ] A throwaway PR proves: direct push is rejected, CI is required, one approval is required.
- [ ] Lefthook is installed and blocks a bad commit message and a lint failure.
- [ ] The board contains the MVP stories, in order, with US-001 in `Ready`.
- [ ] Every teammate ran the app locally and read `CLAUDE.md` and `docs/process/`.

Next step: start [US-001](user-stories/mvp/US-001-walking-skeleton.md).
