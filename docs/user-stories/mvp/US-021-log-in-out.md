# US-021 — Log in and log out

- **Epic:** Accounts
- **Size:** S
- **Depends on:** US-020
- **Status:** Backlog

## Story

As a **student**, I want **to log in and out**, so that **only I can see and change my progress**.

## Rules and notes

- After login, return to the page the user wanted, otherwise to their plan or the plans list.
- Header shows sign-in or the user menu with sign-out.
- Failed logins show a generic message (no account enumeration). Throttling of attempts is a later hardening story.

## Out of scope

- "Remember me" tuning, social login.

## Acceptance criteria

Target file: `features/accounts/log_in_out.feature`

```gherkin
@accounts @US-021
Feature: Log in and out
  Scenario: A student logs in
    Given a registered student
    When I log in with the right credentials
    Then I should be signed in

  Scenario: Wrong credentials are rejected
    Given a registered student
    When I log in with a wrong password
    Then I should see the invalid credentials message
    And I should not be signed in

  Scenario: A student logs out
    Given I am signed in as a student
    When I log out
    Then I should not be signed in
```

## Technical notes

- Devise sessions views customised with daisyUI; layout partial for the header.
