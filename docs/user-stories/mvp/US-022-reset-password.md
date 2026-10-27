# US-022 — Reset my password

- **Epic:** Accounts
- **Size:** S
- **Depends on:** US-021
- **Status:** Backlog

## Story

As a **student**, I want **to reset my password by email**, so that **I can recover my account if I forget it**.

## Rules and notes

- Devise recoverable. The mail is in Spanish. The response never reveals whether an email exists.
- In development, mails open in Mailpit (Compose service). Production sender is chosen in a later story.

## Out of scope

- Choosing the production mail provider (see tools/later).

## Acceptance criteria

Target file: `features/accounts/reset_password.feature`

```gherkin
@accounts @US-022
Feature: Reset password
  Scenario: A student asks for a reset link
    Given a registered student
    When I request a password reset for their email
    Then a reset email should be sent to them

  Scenario: A student sets a new password
    Given a registered student with a reset link
    When I follow the link and set a new password
    Then I should be able to log in with the new password

  Scenario: An unknown email gives the same answer
    When I request a password reset for an unknown email
    Then I should see the same confirmation message
    And no email should be sent
```

## Technical notes

- Mailer previews; `ActionMailer` test delivery in specs.
