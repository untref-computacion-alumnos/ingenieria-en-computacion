# US-011 — View a plan as a grid by year and term

- **Epic:** Curriculum
- **Size:** M
- **Depends on:** US-010
- **Status:** Backlog

## Story

As a **visitor**, I want **to see a study plan as a grid of subjects by year and term**, so that **I understand the whole degree at a glance**.

## Rules and notes

- One column per year/term, subject cards stacked inside, like unimalla's grid.
- Responsive: horizontal scroll on narrow screens; keyboard focusable cards.
- Electives are shown in their own group when the plan defines them (display only for now).

## Out of scope

- Progress colors, prerequisite highlight, subject detail.

## Acceptance criteria

Target file: `features/curriculum/view_plan_grid.feature`

```gherkin
@curriculum @US-011
Feature: View a plan grid
  Scenario: Subjects are grouped by year and term
    Given the study plan "2018" has subjects in year 1 term 1 and year 1 term 2
    When I open the study plan "2018"
    Then I should see year 1 term 1 with its subjects
    And I should see year 1 term 2 with its subjects

  Scenario: An unknown plan is not found
    When I open a study plan that does not exist
    Then I should see the not found page
```

## Technical notes

- `StudyPlansController#show`, `PlanGridComponent`, `SubjectCardComponent` (states added in later stories).
- Eager-load subjects to avoid N+1 (Bullet).
