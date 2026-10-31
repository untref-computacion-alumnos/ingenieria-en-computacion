# US-001 — Implementation steps

Working guide for [US-001](US-001-walking-skeleton.md). The story file is the spec; this file is the
order of work. Every "red" step must be seen failing **for the expected reason** before moving on,
but **red work is never committed**: a commit (`type(us-001): description`) is made only when the
suite is green again, so every commit passes `bin/ci` and the hooks. The red steps stay in the working
tree until the green step resolves them.

Decisions taken for this story:

| Item | Value | I18n key |
| --- | --- | --- |
| Application name | `MiMalla` | `app.name` |
| Home tagline | `Seguí tu avance en Ingeniería en Computación.` | `home.tagline` |

Starting point (already in the repo): `root "home#index"`, an empty `HomeController#index`, and a
`home/index.html.erb` with a hard-coded `<h1>`. The `.feature` exists but has no step definitions.

## Step 0 — Branch and baseline

- [ ] Stay on `us-001-walking-skeleton-deployed-to-test`.
- [ ] Run `bin/ci` and confirm the **only** failure is the three undefined Cucumber steps.

## Step 1 — BDD red: the feature fails because its steps do not exist

The feature is the executable spec, so it is already written
(`features/foundation/home_page.feature`). Run it alone and watch it fail:

```bash
bundle exec cucumber features/foundation/home_page.feature
```

- Expected: `3 steps (3 undefined)`.
- **No commit:** the suite is red.

## Step 2 — BDD red: define the steps so they fail on behavior

Create `features/step_definitions/home_page_steps.rb`. Steps resolve I18n keys, never literal copy:

```ruby
# frozen_string_literal: true

When("I visit the home page") do
  visit root_path
end

Then("I should see the application name") do
  expect(page).to have_content(I18n.t("app.name"))
end

Then("I should see the home tagline") do
  expect(page).to have_content(I18n.t("home.tagline"))
end
```

- Run the feature again. Expected: **red**, because `app.name` and `home.tagline` do not exist yet
  (translation missing) and the page still shows the hard-coded heading.
- If the failure is anything else (routing error, driver error), fix that before continuing.
- **No commit:** still red.

## Step 3 — TDD red: a request spec for `GET /`

The Cucumber scenario is slow and broad; the spec pins the contract at the controller level.
Create `spec/requests/home_spec.rb`:

```ruby
# frozen_string_literal: true

RSpec.describe "Home" do
  describe "GET /" do
    before { get root_path }

    it "responds successfully" do
      expect(response).to have_http_status(:ok)
    end

    it "shows the application name" do
      expect(response.body).to include(I18n.t("app.name"))
    end

    it "shows the tagline" do
      expect(response.body).to include(I18n.t("home.tagline"))
    end
  end
end
```

- Run `bundle exec rspec spec/requests/home_spec.rb`.
- Expected: the first example passes (the route and controller already exist), the other two are
  **red**. That is fine: the spec documents what is missing.
- **No commit:** still red.

## Step 4 — Green: the minimal change

Do only what turns the tests green.

1. Add the keys to `config/locales/es-AR.yml`:

   ```yaml
   ---
   es-AR:
     app:
       name: MiMalla
     home:
       tagline: Seguí tu avance en Ingeniería en Computación.
   ```

2. Replace the hard-coded heading in `app/views/home/index.html.erb`:

   ```erb
   <h1 class="text-3xl font-bold"><%= t("app.name") %></h1>
   <p><%= t("home.tagline") %></p>
   ```

3. Run, in this order: the request spec, the feature, then the whole `bundle exec rspec`.

- Watch out for `spec/i18n_spec.rb`: `config/i18n-tasks.yml` lists `locales: [es-AR, es, en]`, so
  `missing keys` may complain about `es` and `en`. Run `bundle exec i18n-tasks missing` and decide
  with the team: either narrow `locales` to `[es-AR]` (the product is Spanish only), or add the keys to
  the other locale files. Also run `bundle exec i18n-tasks normalize` if the "normalized" example fails.
- Run `bin/ci`. When it is green, make the **first commit of the story**. It contains the feature,
  the step definitions, the request spec, the locale keys and the view, because the red work and the
  code that resolves it belong together:
  `feat(us-001): render app name and tagline on home page`.

## Step 5 — Refactor (tests stay green)

Small, behavior-preserving cleanups only; styling beyond the layout is out of scope.

- [ ] Layout `app/views/layouts/application.html.erb`: set `<html lang="es-AR">`, use
  `t("app.name")` for the default `<title>` and the `application-name` meta tag instead of
  `"Ingenieria En Computacion"`.
- [ ] Give `<main>` a sensible layout with Tailwind (and daisyUI components once the plugin is
  installed; today `application.css` has no daisyUI reference, so check `docs/tools/now.md` first and do
  not add a gem or package that is not listed there without asking).
- [ ] Re-run `bundle exec rspec` and the feature after every change. If anything turns red, undo
  the last change instead of committing it.
- Commit once `bin/ci` is green: `refactor(us-001): use I18n in layout title and set page language`.

## Step 6 — Definition of Done locally

- [ ] Every commit on the branch passed `bin/ci` (no red commits in the history).
- [ ] The Render files (`render.yaml`, `config/`) go in their own green commit, e.g.
  `chore(us-001): configure Render deployment`, made before or after the home page commits.
- [ ] `bin/ci` is fully green (lint, Brakeman, bundler-audit, RSpec + Cucumber).
- [ ] Coverage is at least 90 % (RSpec is at 100 % today; keep it there).
- [ ] No literal UI copy in `.feature` files or step definitions.

## Step 7 — Pipeline: branch to PR to `main`

- [ ] Push the story branch and open a PR to `main` using `.github/pull_request_template.md`.
- [ ] CI (`.github/workflows/ci.yml`) is green and there is at least one approval.
- [ ] Merge with a **merge commit** (no squash, no rebase).

## Step 8 — Deploy to `test` on Render

Prepared in this branch: `render.yaml`, `config/database.yml` (all four Solid databases use
`DATABASE_URL`) and SSL in `config/environments/production.rb`.

- [ ] In Render, create a Blueprint from the repo and set `RAILS_MASTER_KEY` (`cat config/master.key`).
- [ ] After the first deploy, set `APP_HOST` to the `*.onrender.com` host.
- [ ] Point the service at the `test` branch so promotion is `main` → `test` through a release PR.
- [ ] Open the URL and check: the page shows **MiMalla** and the tagline, `/up` answers 200, and the
  logs show `db:prepare` finishing without errors.
- [ ] Remember the free Render Postgres expires after 30 days; use a paid plan (or an external free
  database) for `prod`.

## Step 9 — Close the story

- [ ] Document the hosting choice in `CLAUDE.md` (the story requires it).
- [ ] The "single database" rule is already met: Solid Queue, Cache and Cable point to the primary one.
- [ ] Open the release PR `main` → `test`, merge it, and confirm the deploy.
- [ ] Set the story status to `Done` in `US-001-walking-skeleton.md` and move the card on the board.

## Checklist against the acceptance criteria

| Criterion | Proven by |
| --- | --- |
| Visitor sees the application name | Cucumber step + request spec |
| Visitor sees the home tagline | Cucumber step + request spec |
| Text comes from I18n | `spec/i18n_spec.rb` + no literal copy in tests |
| Story branch → PR → CI green → merge → release PR → deployed | Steps 7 to 9 |
