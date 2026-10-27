# US-031 — See which subjects I can take

- **Epic:** Progress
- **Size:** M
- **Depends on:** US-030
- **Status:** Backlog

## Story

As a **student**, I want **each subject marked as available or blocked according to my progress and its prerequisites**, so that **I know what I can take next**.

## Rules and notes

- Course prerequisite is met when each required subject is `regular`, `approved` or `promoted`.
- A subject is **available** (all prerequisites met), **blocked** (some missing) or already has the student's own status.
- A blocked subject cannot be set to `in_progress`; the detail lists the missing prerequisites.
- Final-exam and count/credit prerequisites are separate backlog stories.

## Out of scope

- Final-exam prerequisites, count-based requirements, OR-alternatives.

## Acceptance criteria

Target file: `features/progress/subject_availability.feature`

```gherkin
@progress @US-031
Feature: Subject availability
  Background:
    Given I am signed in as a student following the plan "2018"
    And the subject "Algebra II" requires "Algebra I"

  Scenario: A subject is blocked until its prerequisite is met
    When I look at the grid
    Then the subject "Algebra II" should be blocked

  Scenario: A subject becomes available
    Given I marked the subject "Algebra I" as regular
    When I look at the grid
    Then the subject "Algebra II" should be available

  Scenario: A blocked subject cannot be started
    When I try to mark the subject "Algebra II" as in progress
    Then I should see which prerequisites are missing
```

## Technical notes

- Service object `Curriculum::Availability` (pure Ruby, heavily unit-tested); preload progress and prerequisites once per request.
- `SubjectCardComponent` gets `state:` variants.
