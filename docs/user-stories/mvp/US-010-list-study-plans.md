# US-010 — List study plans

- **Epic:** Curriculum
- **Size:** S
- **Depends on:** US-002
- **Status:** Backlog

## Story

As a **visitor**, I want **to see the available study plans of the career**, so that **I can open the one that applies to me**.

## Rules and notes

- Public page, no login. Ordered newest first; the active plan is marked.
- Each item shows the plan year and the number of subjects.

## Out of scope

- Comparing plans, equivalences.

## Acceptance criteria

Target file: `features/curriculum/list_study_plans.feature`

```gherkin
@curriculum @US-010
Feature: List study plans
  Scenario: A visitor sees the available plans
    Given the study plans "2011" and "2018" exist
    When I visit the study plans page
    Then I should see the plans "2018" and "2011" in that order
    And the plan "2018" should be marked as the active plan
```

## Technical notes

- `StudyPlansController#index`, `StudyPlanCardComponent`.
