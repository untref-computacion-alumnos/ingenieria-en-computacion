# Ingeniería en Computación

[Español](README_ES.md) · English

Web application for the Computer Engineering program, built with Ruby on
Rails. Work is driven by user stories (`US-XXX`) and delivered through
small, tested pull requests.

## Stack

| Area                 | Tools                                                      |
| -------------------- | ---------------------------------------------------------- |
| Language / framework | Ruby 4.0.9, Rails 8.1                                      |
| Database             | PostgreSQL 17 (Solid Queue, Cache and Cable in production) |
| Front end            | Hotwire, Tailwind CSS 4 + daisyUI, ViewComponent           |
| Auth                 | Devise, Pundit, Rolify                                     |
| Tests                | RSpec, Cucumber, Capybara + Cuprite, SimpleCov             |
| Linters              | RuboCop, ERB Lint, markdownlint, yamllint, cuke_linter     |
| Analysis             | i18n-tasks, Reek, Rails Best Practices                     |
| Security             | Brakeman, bundler-audit                                    |
| Tooling              | Docker Compose, Lefthook, GitHub Actions                   |

## Requirements

Recommended (Docker):

- Git
- Docker with Compose v2

Optional, for native work without Docker:

- [mise](https://mise.jdx.dev) (or rbenv/asdf) with Ruby from `.ruby-version`
- PostgreSQL and its client libraries (`libpq`)
- Node LTS (markdownlint, commitlint) and `yamllint`

## Getting started

### With Docker (recommended)

```bash
git clone git@github.com:<org>/<repo>.git

cd ingenieria-en-computacion

docker compose up --build
```

| Service                                | URL                     |
| -------------------------------------- | ----------------------- |
| Application                            | <http://localhost:3000> |
| Mailpit (emails caught in development) | <http://localhost:8025> |

The `web` container installs gems, prepares the database
(`bin/rails db:prepare`) and runs `bin/dev` (Puma + Tailwind watcher).

Run any command inside the container with `bin/dc`:

```bash
bin/dc bin/rails console

bin/dc bin/rails db:migrate

bin/dc bundle exec rspec
```

### Natively

```bash
mise install            # Ruby from mise.toml / .ruby-version

bundle install

bin/rails db:prepare

bin/dev
```

Prefix `bin/dc` commands with `LOCAL=1` to run them without Docker.

## Configuration

| Variable       | Default                            | Purpose                                      |
| -------------- | ---------------------------------- | -------------------------------------------- |
| `DB_HOST`      | `localhost` (`db` in Compose)      | PostgreSQL host                              |
| `DB_USER`      | `postgres`                         | PostgreSQL user                              |
| `DB_PASSWORD`  | `postgres`                         | PostgreSQL password                          |
| `SMTP_HOST`    | `localhost` (`mailpit` in Compose) | Development mail server                      |
| `COVERAGE_MIN` | `90`                               | Minimum line coverage (`bin/coverage-check`) |

Secrets never go in git: use Rails credentials and GitHub secrets.

## Database

```bash
bin/dc bin/rails db:prepare   # create, migrate and seed if needed

bin/dc bin/rails db:reset     # drop and recreate (development only)
```

## Tests and quality checks

```bash
bin/dc bundle exec rspec      # unit / request / component specs

bin/dc bundle exec cucumber   # acceptance scenarios (features/)

bin/dc bin/ci                 # everything CI runs: linters, security,
                              # specs, scenarios and coverage (≥ 90 %)
```

Lefthook runs the linters (on the whole project) on commit, validates the
author name, pre-fills the story scope in the commit message from the
branch name, validates the message, and runs the RSpec suite (`bin/ci-quick`) on push.
Run `bin/dc bin/ci` by hand before the last push of a story. The hooks run
on the host, not in the container. Install them once with
`bundle exec lefthook install`.

## Services

- **PostgreSQL**: primary database.
- **Mailpit**: SMTP sink for development emails.
- **Solid Queue / Cache / Cable**: background jobs, cache and Action Cable
  backed by the database (separate databases in production).

## Deployment

Branches: `main` (integration), `test` (staging) and `prod` (production).
All three are protected: changes arrive only through pull requests with
passing CI and one approval, merged with a merge commit. Hosting is still
being decided; the choice will be recorded in `CLAUDE.md`.

## Documentation

- [Contributing guide](CONTRIBUTING.md)
- [Skeleton setup guide](docs/skeleton.md)
- [User stories](user-stories/README.md)
- [Process docs](docs/process/definition-of-done.md)
- [CLAUDE.md](CLAUDE.md): conventions for humans and AI assistants
