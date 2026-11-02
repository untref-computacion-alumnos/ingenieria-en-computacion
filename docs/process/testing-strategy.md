# Testing strategy: SDD + BDD + TDD

## The loop for every user story

1. **SDD — spec first.** The story file in `docs/user-stories/` is the spec: rules, out of scope,
   acceptance criteria.
2. **BDD — executable acceptance.** Turn the criteria into `features/<epic>/<name>.feature`
   (Gherkin, English). Run Cucumber: it is **red**.
3. **TDD — inside-out.** For each missing piece write an RSpec example first (red), make it pass (green),
   then refactor. Repeat until the Cucumber scenario is green.
4. Before the last push of the story, run `bin/ci` (linters, security, advisory checks, tests), then open the PR.

## Who tests what

| Layer | Tool | Examples |
| --- | --- | --- |
| Acceptance (user behavior) | Cucumber + Capybara (Cuprite driver) | "student marks a subject as approved" |
| Models, services, queries | RSpec + FactoryBot + Shoulda Matchers | prerequisite resolution |
| Authorization | RSpec + pundit-matchers | who can edit a subject |
| Components | RSpec + ViewComponent test helpers | subject card in each state |
| Requests / controllers | RSpec request specs | redirects, JSON/Turbo Stream responses |
| Jobs / mailers | RSpec | import job, reset-password mail |

Rules of thumb: many fast RSpec examples, few Cucumber scenarios (one set per story, happy path plus
the key rules). Minitest is **not** used (the app is generated with `--skip-test`).

## The story and the `.feature`

- The story markdown drafts the Gherkin and names the target file (`features/...`).
- Once the `.feature` exists in the repo it is the source of truth. The story's Gherkin block is a draft and is
  not checked automatically, so do not spend time keeping both identical.

## Gherkin conventions

- English, third-person domain language, no UI details ("click the blue button").
- One `Feature` per file, named after the story; use `Background` for shared setup.
- **No literal UI copy.** Steps resolve I18n keys (for example "I should see the sign-in success message");
  quoted values are domain data only (subject names, years).
- Tag by epic and story: `@curriculum @US-011`; use `@javascript` only when Turbo/Stimulus behavior needs a real browser.
- `cuke_linter` enforces scenario naming, no duplicated steps, and Given/When/Then order.

## Test data

- FactoryBot factories in `spec/factories`; Faker only for incidental values.
- A small realistic seed of the real study plan is used in features through a helper step,
  never the full production data.

## Coverage

- SimpleCov merges RSpec and Cucumber runs; CI fails below **90 %**.
- Coverage is a floor, not a goal: untested rules matter more than the percentage.

## Branch discipline

Every PR runs the full suite in CI; `bin/ci` runs the same commands locally (Docker or native).
