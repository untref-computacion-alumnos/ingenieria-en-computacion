# US-05 — See a subject's detail

- **Epic:** Curriculum
- **Size:** S
- **Depends on:** US-04
- **Status:** In progress

## Story

As a **visitor**, I want **to open a subject and see its details and prerequisites**, so that **I know what it requires and how heavy it is**.

## Rules and notes

- Opens in a **side panel** (decided) using a Turbo Frame; also reachable by its own URL (`/subjects/:id`).
  On small screens the panel is full screen. Focus moves to the panel heading when it opens.
- Shows name, code, year/term, hours or credits, and the list of prerequisites (linked subjects).

- Hours and credits are shown only when the subject has them.
- This story also lays the **style foundation** for every later story: see the
  [style guide](../../design/style-guide.md) (themes, tokens, Inter, status colors, accessibility, enforcement spec).

## Out of scope

- Syllabus, teachers, reviews.
- Subject status colors in the UI (the tokens exist; US-11 uses them), manual dark-mode switch.

## Acceptance criteria

Target file: `features/curriculum/subject_detail.feature`

```gherkin
@curriculum @US-05
Feature: Subject detail
  Scenario: A visitor opens a subject from the grid
    Given the subject "Algebra II" requires "Algebra I"
    When I open the subject "Algebra II" from the grid
    Then I should see the subject details
    And I should see "Algebra I" listed as a prerequisite
```

## Technical notes

- `SubjectsController#show`, Turbo Frame `subject_detail`, `SubjectDetailComponent`.
