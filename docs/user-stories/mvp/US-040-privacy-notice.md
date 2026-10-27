# US-040 — Privacy notice and terms

- **Epic:** Privacy
- **Size:** S
- **Depends on:** US-020
- **Status:** Backlog

## Story

As a **visitor or student**, I want **to read what data is stored and how it is used**, so that **I can decide to trust the app**.

## Rules and notes

- Static pages `/privacy` and `/terms` in Spanish (I18n or markdown partials); linked from the footer and from the sign-up form.
- Sign-up requires accepting the terms (checkbox, timestamp stored).
- States: progress is private by default; data export/delete arrives in a following story (US-2xx) and is announced as coming.
- Have the text reviewed by the team; it is not legal advice.

## Out of scope

- Cookie banner (no tracking cookies are used), export/delete functionality.

## Acceptance criteria

Target file: `features/privacy/privacy_notice.feature`

```gherkin
@privacy @US-040
Feature: Privacy notice and terms
  Scenario: Anyone can read the notice and terms
    When I visit the privacy page
    Then I should see the privacy notice
    When I visit the terms page
    Then I should see the terms

  Scenario: Sign-up requires accepting the terms
    When I sign up without accepting the terms
    Then I should see an error about accepting the terms
    And I should not be signed in
```

## Technical notes

- `users.terms_accepted_at`; `PagesController`; footer partial.
