# US-012 — See a subject's detail

- **Epic:** Curriculum
- **Size:** S
- **Depends on:** US-011
- **Status:** Backlog

## Story

As a **visitor**, I want **to open a subject and see its details and prerequisites**, so that **I know what it requires and how heavy it is**.

## Rules and notes

- Opens in a side panel/modal using a Turbo Frame; also reachable by its own URL.
- Shows name, code, year/term, hours or credits, and the list of prerequisites (linked subjects).

## Out of scope

- Syllabus, teachers, reviews.

## Acceptance criteria

Target file: `features/curriculum/subject_detail.feature`

```gherkin
@curriculum @US-012
Feature: Subject detail
  Scenario: A visitor opens a subject from the grid
    Given the subject "Algebra II" requires "Algebra I"
    When I open the subject "Algebra II" from the grid
    Then I should see the subject details
    And I should see "Algebra I" listed as a prerequisite
```

## Technical notes

- `SubjectsController#show`, Turbo Frame `subject_detail`, `SubjectDetailComponent`.
