# CLAUDE.md — Project context

This file is the persistent context for Claude Code. Read it first, then follow the links.
Keep it short and accurate; details live in `docs/`. Update it when a decision changes.

## What we are building

A Ruby on Rails web app (PostgreSQL) for **one university degree: Ingeniería en Computación**.
It started as a curriculum grid ("malla") inspired by unimalla.com, adapted to a single career whose
study plans changed several times. It must stay **lean**: only things that help a student (later also
teachers) with the degree and the faculty, integrated with faculty systems, never an extra burden.
Everything beyond the grid is added incrementally, and non-essential tools are **optional modules**.

Details: [docs/product/vision.md](docs/product/vision.md), [docs/product/domain.md](docs/product/domain.md).

## Audience priority

1. Students (everything is built for them first)
2. Teachers
3. Applicants (ingresantes)
4. Admins / student center (maintenance tooling that serves the above; needed early but minimal)

## Product decisions (from the discovery questionnaire)

- Scope: a single career. Study plans are **versioned** (e.g. 2011, 2018…) with **equivalences** between plans.
- Login: email + password now (Devise); Google OAuth later; faculty login maybe much later.
- Anonymous mode: anyone can view the grid; saving progress requires an account.
- Subject statuses: pending / in progress / regular / approved / promoted (with or without final exam),
  plus free / retaking / dropped; grade + approval date.
- Prerequisites: to take the course (regular or approved), to sit the final (approved), and by count/credits.
  OR-alternatives are **not** required for now.
- Structure: years/terms, electives, intermediate degree, extra requirements (language, internship, thesis).
- Data: admin panel + seeds, plus CSV import, plus change proposals from users (moderated).
- Future community: suggestions board with votes + threads + categories + per-subject discussion;
  reviews of subjects/teachers (anonymous-verified or public, structured ratings, moderation queue,
  anti-abuse filters).
- Future organization: exam/enrollment calendar, schedule, tasks per subject, notifications,
  grades + average + "what do I need" calculator, syllabi, exam/notes repository.
- Integrations (later): SIU Guaraní (manual file import first, API if the faculty grants access),
  Educativa Mobile classroom (NOT assumed to be Moodle), faculty website news,
  iCal/Google Calendar, Telegram bot, web push.
- Pomodoro, notes and attendance: last, as optional modules behind feature flags.
- Privacy: progress private by default, verified-student check via institutional email,
  export/delete my data, privacy notice + terms.
- MVP = **grid + account + progress**. See [docs/user-stories/](docs/user-stories/README.md).

## Stack (decided)

Rails 8.x · PostgreSQL · Hotwire (Turbo + Stimulus) · Tailwind CSS + daisyUI · ViewComponent ·
Devise + Pundit + Rolify · Solid Queue · Flipper (feature flags) · I18n es-AR (code & docs in English,
screen text in Spanish) · RSpec + Cucumber (Gherkin in English) + Capybara · Docker Compose dev env.
Full list: [docs/tools/now.md](docs/tools/now.md) and [docs/tools/later.md](docs/tools/later.md).

## Process (decided)

- Small team (2–3, mostly Rails beginners). Scrumban leaning to light Scrum, GitHub Projects as the board.
- **WIP = 1**: the team works on one user story at a time; stories are tiny.
- Branches `main`, `test`, `prod` are protected; no direct commits. Only PRs with **merge commits**.
  One short-lived branch per user story → PR to `main` (CI) → promote `main`→`test`→`prod` via PRs.
  `test` and `prod` deploy to web environments.
- Method: BDD (Cucumber `.feature` per story) → TDD (RSpec red/green/refactor) → spec-driven
  (the user-story markdown is the spec; the `.feature` is the executable source of truth).
- Definition of Done: tests green, linters clean, coverage ≥ 90 %, Brakeman + bundler-audit clean,
  ≥ 1 PR approval. See [docs/process/definition-of-done.md](docs/process/definition-of-done.md).

Process docs: [agile](docs/process/agile.md) · [git workflow](docs/process/git-workflow.md) ·
[testing](docs/process/testing-strategy.md).
Skeleton setup guide: [docs/skeleton.md](docs/skeleton.md).

## Conventions

- Code, comments, commits, docs, `.feature` files: **English**. User-visible text: **Spanish (es-AR)** via I18n.
  Never put literal UI copy in `.feature` files; steps resolve I18n keys.
- Domain terms Spanish → English are fixed in the glossary ([domain.md](docs/product/domain.md)).
- Branch names `us-<id>-<slug>`; commit messages are `type(us-NN): description`,
  e.g. `feat(us-011): render grid by term` (Lefthook enforces it).
- Do not use Minitest; the app is generated with `--skip-test`.
- Prefer boring Rails conventions over cleverness; the team is learning.

## Working agreement for Claude

- Work on one user story at a time, following the story file as the spec.
- Write/adjust the `.feature` first, then specs, then code; run linters before proposing a commit.
- Do not add a gem that is not listed in `docs/tools/now.md` without asking; move deferred ones from
  `later.md` only when their trigger story starts.
- Commits are guarded by Lefthook (linters) and pushes by `bin/ci-quick` (RSpec only). Run the full `bin/ci`
  (`bin/lint`, `bin/security`, `bin/advisory`, `bin/test`) before the last push of a story / before opening the PR.
- Never commit to `main`/`test`/`prod` directly; never skip hooks.
