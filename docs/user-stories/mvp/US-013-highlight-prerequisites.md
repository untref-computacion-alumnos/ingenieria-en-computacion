# US-013 — Highlight prerequisites on interaction

- **Epic:** Curriculum
- **Size:** M
- **Depends on:** US-011
- **Status:** Backlog

## Story

As a **visitor**, I want **related subjects highlighted when I hover or select a subject**, so that **I see its prerequisites and the subjects it unlocks without opening each one**.

## Rules and notes

- Selecting a card highlights its prerequisites (one colour) and the subjects that depend on it (another).
- Works with touch (tap to select) and keyboard (focus); a second tap clears.
- The grid carries prerequisite ids in `data-` attributes; a Stimulus controller toggles CSS classes. No arrows.

## Out of scope

- Drawing arrows between cards; progress states.

## Acceptance criteria

Target file: `features/curriculum/highlight_prerequisites.feature`

```gherkin
@curriculum @javascript @US-013
Feature: Highlight prerequisites
  Scenario: Selecting a subject highlights what it needs and unlocks
    Given the subject "Algebra II" requires "Algebra I" and unlocks "Analysis II"
    When I select the subject "Algebra II" in the grid
    Then "Algebra I" should be highlighted as a prerequisite
    And "Analysis II" should be highlighted as unlocked

  Scenario: Selecting again clears the highlight
    Given I selected the subject "Algebra II" in the grid
    When I select the subject "Algebra II" in the grid
    Then no subject should be highlighted
```

## Technical notes

- Stimulus controller `grid_highlight_controller.js`; data attributes from `SubjectCardComponent`.
