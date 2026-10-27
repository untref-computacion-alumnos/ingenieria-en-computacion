# US-033 — Record grade and approval date

- **Epic:** Progress
- **Size:** S
- **Depends on:** US-030
- **Status:** Backlog

## Story

As a **student**, I want **to save the grade and date when I approve or promote a subject**, so that **I keep my academic record in one place**.

## Rules and notes

- Grade and date are optional, so marking a subject is never blocked. Grade 1–10 (integer or one decimal); date not in the future.
- For `promoted`, a flag records whether a final exam was sat.
- Fields appear in the subject detail panel when the status needs them.

## Out of scope

- Average and "what grade do I need" (student tools backlog).

## Acceptance criteria

Target file: `features/progress/grade_and_date.feature`

```gherkin
@progress @US-033
Feature: Grade and approval date
  Background:
    Given I am signed in as a student following the plan "2018"

  Scenario: Saving a grade and date
    Given I marked the subject "Algebra I" as approved
    When I save the grade 8 and the date "2024-12-10" for "Algebra I"
    Then the subject "Algebra I" should show grade 8 and that date

  Scenario: An invalid grade is rejected
    Given I marked the subject "Algebra I" as approved
    When I save the grade 11 for "Algebra I"
    Then I should see an error about the grade

  Scenario: A future date is rejected
    Given I marked the subject "Algebra I" as approved
    When I save a date in the future for "Algebra I"
    Then I should see an error about the date
```

## Technical notes

- Columns `grade` (decimal), `approved_on` (date), `final_exam_taken` (boolean) on `subject_progresses`; model validations with Shoulda.
