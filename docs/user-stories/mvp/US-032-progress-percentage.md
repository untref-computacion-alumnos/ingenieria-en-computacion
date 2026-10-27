# US-032 — See my progress percentage

- **Epic:** Progress
- **Size:** S
- **Depends on:** US-030
- **Status:** Backlog

## Story

As a **student**, I want **to see how much of my degree I have completed**, so that **I feel progress and know what is left**.

## Rules and notes

- Percentage = approved or promoted subjects / total subjects of the plan (rounded down, shown with counts, e.g. "12 / 40").
- Shown above the grid for signed-in students with a plan.
- Weighting by credits/hours is a later refinement.

## Out of scope

- Charts, per-year breakdown, electives credit pools.

## Acceptance criteria

Target file: `features/progress/progress_percentage.feature`

```gherkin
@progress @US-032
Feature: Progress percentage
  Scenario: A student sees their progress
    Given I am signed in as a student following a plan with 40 subjects
    And I have 10 subjects approved and 2 promoted
    When I look at the grid
    Then I should see 12 of 40 subjects completed
    And I should see 30 percent

  Scenario: A new student has no progress
    Given I am signed in as a student following a plan with 40 subjects
    When I look at the grid
    Then I should see 0 of 40 subjects completed
```

## Technical notes

- `Curriculum::ProgressSummary` service + `ProgressBarComponent` (daisyUI progress).
