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

## Step 5 — Layout: page language and title (red, then green)

Steps 5 to 11 repeat the same rhythm: write the failing check, see it fail for the right reason, make
the smallest change that fixes it, run the suite, commit only when green.

The layout still hard-codes `Ingenieria En Computacion` in `<title>` and in the `application-name`
meta tag, and the `<html>` tag has no `lang`. Screen readers and browsers rely on `lang`, and the
title must come from I18n like every other visible text.

### 5.1 Red: add two examples to the request spec

In `spec/requests/home_spec.rb`, inside the existing `describe "GET /"` block, add:

```ruby
    it "declares the page language" do
      expect(response.body).to include('lang="es-AR"')
    end

    it "uses the application name as the page title" do
      expect(response.body).to include("<title>#{I18n.t("app.name")}</title>")
    end
```

Run it and check that the two new examples fail for the right reason (the markup does not match),
not because of a typo:

```bash
bundle exec rspec spec/requests/home_spec.rb
```

Expected: `5 examples, 2 failures`. **No commit:** red.

### 5.2 Green: change the layout

In `app/views/layouts/application.html.erb`, change the opening `<html>` tag, the `<title>` and the
`application-name` meta tag. Everything else stays as it is.

```erb
<!DOCTYPE html>
<html lang="<%= I18n.locale %>">
  <head>
    <title><%= content_for(:title) || t("app.name") %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="application-name" content="<%= t("app.name") %>">
```

`I18n.locale` is `:"es-AR"` (set in `config/application.rb`), so the output is `lang="es-AR"` without
repeating the string anywhere.

Run the spec again, then the feature, then the linters that look at ERB and I18n:

```bash
bundle exec rspec spec/requests/home_spec.rb
bundle exec cucumber features/foundation/home_page.feature
bundle exec erb_lint --lint-all
bundle exec i18n-tasks health
```

Expected: `5 examples, 0 failures`, `1 scenario (1 passed)` and no lint offenses.

### 5.3 Commit

```bash
bin/ci
git add app/views/layouts/application.html.erb spec/requests/home_spec.rb
git commit -m "feat(us-001): set page language and title from I18n"
```

## Step 6 — Home page look with daisyUI (visual refactor)

Out of scope for the story is "styling beyond the layout", so this step only centers the content with
one daisyUI component. daisyUI is already installed: `app/assets/tailwind/application.css` loads it
with `@plugin "./daisyui.mjs"`, so no gem or package is added.

This is a pure refactor: the markup changes, the visible text does not, so the existing tests are the
safety net and no new test is needed.

### 6.1 The home view

Replace the content of `app/views/home/index.html.erb`:

```erb
<section class="hero min-h-[60vh]">
  <div class="hero-content text-center">
    <div class="max-w-md">
      <h1 class="text-5xl font-bold"><%= t("app.name") %></h1>
      <p class="py-6 text-lg"><%= t("home.tagline") %></p>
    </div>
  </div>
</section>
```

### 6.2 The layout container

The old `<main>` pushed everything down with `mt-28` and used `flex`. A hero does not need either. In
`app/views/layouts/application.html.erb`:

```erb
  <body>
    <main class="container mx-auto px-5">
      <%= yield %>
    </main>
  </body>
```

### 6.3 Check it in the browser and in the suite

Tailwind compiles the classes on the fly with `bin/dev`, so look at the result before running the
suite. You need Postgres running (`docker compose up db -d`, or the whole stack with `docker compose up`).

```bash
bin/dev
```

Open `http://localhost:3000`: the name and the tagline must be centered, with no horizontal scroll on
a narrow window. Stop the server with `Ctrl-C`, then:

```bash
bin/ci
```

If any test turns red, undo the last edit instead of patching the test. Then commit:

```bash
git add app/views/home/index.html.erb app/views/layouts/application.html.erb
git commit -m "feat(us-001): center home content with a daisyUI hero"
```

## Step 7 — Group the remaining changes into green commits

At this point the working tree still holds the changes that fixed `bin/ci` and the Render files. Each
commit must pass the hooks on its own, so stage them by topic and never use `--no-verify`.

Check what is left:

```bash
git status --short
```

### 7.1 The story itself

If you did not commit it in step 4, this is the **first commit of the story**: the feature, its
description (kept identical in the story file so `bin/check-stories` stays in sync), the step
definitions, the request spec, the locale keys, the view and the two small configuration fixes the
suite needed (spec type inference and a single locale in `i18n-tasks`).

```bash
git add features/foundation/home_page.feature \
        features/step_definitions/home_page_steps.rb \
        docs/user-stories/mvp/US-001-walking-skeleton.md \
        spec/requests/home_spec.rb spec/rails_helper.rb \
        config/locales/es-AR.yml config/i18n-tasks.yml \
        app/views/home/index.html.erb
git commit -m "feat(us-001): render app name and tagline on home page"
```

### 7.2 Security advisory in `rack`

`bundler-audit` fails on `rack 3.2.7`. Update only that gem and check that nothing else moved:

```bash
bundle update rack
git diff Gemfile.lock
git add Gemfile Gemfile.lock
git commit -m "chore(us-001): update rack to fix security advisories"
```

### 7.3 Render deployment

```bash
git add render.yaml .gitignore config/database.yml config/environments/production.rb
git commit -m "chore(us-001): configure Render deployment"
```

`render.env` is git-ignored on purpose; `git status` must not list it. Confirm with:

```bash
git check-ignore -v render.env
```

### 7.4 This guide

```bash
git add docs/user-stories/mvp/US-001-steps.md
git commit -m "docs(us-001): add implementation steps"
```

### 7.5 Final local check

Every commit must be green, not only the last one. Re-test the whole branch:

```bash
git log --oneline main..HEAD
bin/ci
```

Coverage is at least 90 % (`coverage/index.html`), and no UI copy is hard-coded anywhere outside the
locale file. This search must return only `config/locales/es-AR.yml` and, at most, the guide:

```bash
grep -rn "MiMalla\|Seguí tu avance" app features spec config
```

## Step 8 — Pull request to `main`

Push the branch and open the PR with the title in commit format. The body follows
`.github/pull_request_template.md`.

```bash
git push -u origin us-001-walking-skeleton-deployed-to-test
```

```bash
gh pr create --base main \
  --title "feat(us-001): walking skeleton with home page and Render deploy" \
  --body "$(cat <<'BODY'
## Story

Story: US-001 (docs/user-stories/mvp/US-001-walking-skeleton.md)

## What and why

Adds the home page (app name and tagline from I18n) and the Render deployment files, so every later
story ships through the same pipeline.

## How to test

1. Run `bundle exec cucumber features/foundation/home_page.feature`.
2. Run `bin/dev` and open http://localhost:3000.

## Definition of done

- [x] .feature scenarios pass
- [x] RSpec added (red → green → refactor)
- [x] Linters clean
- [x] Coverage ≥ 90 %, Brakeman and bundler-audit clean
- [x] No hard-coded UI text (I18n)
- [x] Docs updated

## Notes for the reviewer

New env vars on Render: RAILS_MASTER_KEY, APP_HOST (see render.yaml).
BODY
)"
```

Watch the CI jobs `lint`, `security` and `test` from the terminal:

```bash
gh pr checks --watch
```

If a job fails, fix it with a new green commit on the same branch (never force-push over a review).
The PR needs one approval from someone who is not the author. Then merge with a **merge commit** and
delete the branch:

```bash
gh pr merge --merge --delete-branch
```

## Step 9 — Release PR `main` → `test`

The Blueprint in `render.yaml` is read from the branch Render is linked to, so `test` must contain the
file before the service is created. Pin the service to that branch by adding one line in `render.yaml`
(do it in the PR of step 8, or in a tiny follow-up PR):

```yaml
services:
  - type: web
    name: ingenieria-en-computacion
    runtime: docker
    branch: test
```

Open the promotion PR. It runs the same CI again:

```bash
git switch main && git pull
gh pr create --base test --head main \
  --title "chore(us-001): release walking skeleton to test" \
  --body "Promotes the merged US-001 work from main to test."
gh pr checks --watch
gh pr merge --merge
```

## Step 10 — Deploy to Render and verify

### 10.1 Create the service from the Blueprint

In the Render dashboard: **New → Blueprint**, choose this repository and the `test` branch. Render
reads `render.yaml` and creates the web service and the database. When it asks for the secrets that
have `sync: false`:

```bash
cat config/master.key
```

Paste that value in `RAILS_MASTER_KEY`. Leave `APP_HOST` empty for now.

### 10.2 Set `APP_HOST`

When the first deploy finishes, copy the service URL (`https://<name>.onrender.com`). In
**Environment**, set `APP_HOST` to the host only, without `https://`, and let Render redeploy. The
values you pasted come from `render.env`, which you keep as a local reference.

### 10.3 Verify from the terminal

Replace `<host>` with your service host:

```bash
curl -I https://<host>/up
curl -s https://<host>/ | grep -E "MiMalla|Seguí tu avance"
```

Expected: `HTTP/2 200` for `/up`, and both texts in the home page. Also read the deploy log in Render:
`db:prepare` must finish without errors and Puma must report that it is listening. If `/up` redirects
in a loop, check that `config.assume_ssl = true` is still set in `production.rb`.

Limits to remember: the free web service sleeps when idle (the first request is slow), jobs pause with
it because Solid Queue runs inside Puma, and the free Render Postgres expires after 30 days. For `prod`
use a paid plan, or an external free database as `docs/skeleton.md` suggests.

## Step 11 — Close the story

These are documentation changes, so they also go through a short PR:

```bash
git switch main && git pull
git switch -c us-001-close-story
```

### 11.1 Record the hosting choice

The story requires the choice to be documented in `CLAUDE.md`. Add this bullet under **Process
(decided)**:

```markdown
- Hosting: Render (Docker web service + Render PostgreSQL), described in `render.yaml`. `test` and
  `prod` deploy from their own branches. Solid Queue, Cache and Cable share the primary database
  (`DATABASE_URL`). Secrets live in the Render dashboard.
```

### 11.2 Mark the story as done

In `docs/user-stories/mvp/US-001-walking-skeleton.md`, change the status line:

```markdown
- **Status:** Done
```

`bin/check-stories` now requires the `.feature` file to exist and match, and it does.

### 11.3 Commit, PR and merge

```bash
bin/ci
git add CLAUDE.md docs/user-stories/mvp/US-001-walking-skeleton.md
git commit -m "docs(us-001): record hosting choice and close story"
git push -u origin us-001-close-story
gh pr create --base main --title "docs(us-001): record hosting choice and close story" \
  --body "Documents the Render choice and sets US-001 to Done after the deploy was verified on test."
```

After the approval and the merge, move the card to **Done** on the GitHub Projects board and start the
next story (WIP = 1).

## Checklist against the acceptance criteria

| Criterion | Proven by |
| --- | --- |
| Visitor sees the application name | Cucumber step + request spec |
| Visitor sees the home tagline | Cucumber step + request spec |
| Page language and title come from I18n | Request spec (step 5) |
| Text comes from I18n | `spec/i18n_spec.rb` + no literal copy in tests |
| Story branch → PR → CI green → merge → release PR → deployed | Steps 8 to 10 |
| Hosting documented | Step 11 |
