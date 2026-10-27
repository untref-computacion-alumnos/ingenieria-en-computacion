# US-023 — Select my study plan

- **Epic:** Accounts
- **Size:** S
- **Depends on:** US-021, US-010
- **Status:** Backlog

## Story

As a **student**, I want **to choose which study plan I follow**, so that **I see my own grid and my progress**.

## Rules and notes

- `User#study_plan` set from a simple form; changeable later (migrating progress between plans is a later story using equivalences).
- A signed-in student without a plan is redirected to the plan picker after login.
- Until progress exists, changing plan is free; once progress is recorded the UI warns that it will be reset (temporary rule, replaced by equivalences later).

## Out of scope

- Progress migration across plans.

## Acceptance criteria

Target file: `features/accounts/select_plan.feature`

```gherkin
@accounts @US-023
Feature: Select my study plan
  Scenario: A student without a plan is asked to choose one
    Given I am signed in as a student without a plan
    When I visit the home page
    Then I should be asked to choose my study plan

  Scenario: A student chooses a plan
    Given I am signed in as a student without a plan
    When I choose the plan "2018"
    Then my plan should be "2018"
    And I should see the grid of "2018"
```

## Technical notes

- `users.study_plan_id`, `Users::StudyPlansController`, Pundit policy (own record only).
