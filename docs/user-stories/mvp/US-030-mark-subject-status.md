# US-030 — Mark a subject's status

- **Epic:** Progress
- **Size:** M
- **Depends on:** US-023, US-012
- **Status:** Backlog

## Story

As a **student**, I want **to set the status of each subject (pending, in progress, regular, approved, promoted)**, so that **the grid reflects where I am**.

## Rules and notes

- Status changes inline through Turbo (no full reload); the card colour reflects the status.
- Default is `pending`; only the owner can change their own progress (Pundit).
- Visitors see the plain grid; trying to mark asks to sign in.
- Whether a requirement allows the change (prerequisites) is enforced in US-031.

## Out of scope

- Grade and date (US-033), free / retaking / dropped statuses, attempt history.

## Acceptance criteria

Target file: `features/progress/mark_subject_status.feature`

```gherkin
@progress @US-030
Feature: Mark a subject's status
  Background:
    Given I am signed in as a student following the plan "2018"

  Scenario: Marking a subject as in progress
    When I mark the subject "Algebra I" as in progress
    Then the subject "Algebra I" should show as in progress

  Scenario: Changing a status
    Given I marked the subject "Algebra I" as regular
    When I mark the subject "Algebra I" as approved
    Then the subject "Algebra I" should show as approved

  Scenario: A visitor is asked to sign in
    Given I am not signed in
    When I try to mark the subject "Algebra I" as approved
    Then I should be asked to sign in
```

## Technical notes

- `SubjectProgress` (user, subject, status enum), unique (user, subject); `SubjectProgressesController#update` with Turbo Stream; `SubjectProgressPolicy`.
