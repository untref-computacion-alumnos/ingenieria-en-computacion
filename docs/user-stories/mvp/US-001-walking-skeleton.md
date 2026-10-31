# US-001 — Walking skeleton deployed to test

- **Epic:** Foundation
- **Size:** M
- **Depends on:** the skeleton from [skeleton.md](../../skeleton.md) (steps 1–9)
- **Status:** Backlog

## Story

As a **developer**, I want **a home page that goes through the whole pipeline (tests, CI, deploy to test)**,
so that **every later story ships the same way from day one**.

## Rules and notes

- Home page shows the app name and a short Spanish tagline from I18n.
- Pipeline proven end to end: story branch → PR → CI green → merge to `main` → release PR to `test` → deployed.
- Decide hosting from the options in the skeleton guide and document the choice in `CLAUDE.md`.
- If hosting offers a single database, point Solid Queue/Cache/Cable to the primary database.

## Out of scope

- Real content, authentication, styling beyond the layout.

## Acceptance criteria

Target file: `features/foundation/home_page.feature`

```gherkin
@foundation @US-001
Feature: Home page
  As a visitor
  I want to see the application name and tagline on the home page
  So that I know what the application is
  Scenario: A visitor opens the home page
    When I visit the home page
    Then I should see the application name
    And I should see the home tagline
```

## Technical notes

- `HomeController#index`, I18n keys `home.*`, layout with Tailwind + daisyUI.
- GitHub Actions `ci.yml`, deploy workflow for `test`, branch rulesets configured.
