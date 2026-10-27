# US-020 — Sign up with email and password

- **Epic:** Accounts
- **Size:** S
- **Depends on:** US-001
- **Status:** Backlog

## Story

As a **visitor**, I want **to create an account with my email and a password**, so that **my progress can be saved**.

## Rules and notes

- Devise `:database_authenticatable, :registerable, :recoverable, :validatable`.
- New users get the `student` role (Rolify). Password minimum length per Devise config (≥ 10 recommended).
- Email confirmation and institutional-email verification are later stories (US-2xx).
- All messages in Spanish through I18n (`devise-i18n` / `rails-i18n`).

## Out of scope

- OAuth, email confirmation, profile page.

## Acceptance criteria

Target file: `features/accounts/sign_up.feature`

```gherkin
@accounts @US-020
Feature: Sign up
  Scenario: A visitor creates an account
    When I sign up with a valid email and password
    Then I should be signed in
    And I should have the student role

  Scenario: An email already in use is rejected
    Given a user exists with the email "ana@example.com"
    When I sign up with the email "ana@example.com"
    Then I should see an error about the email being taken
    And I should not be signed in
```

## Technical notes

- `User` model with Devise; seed roles; request and model specs for validations.
