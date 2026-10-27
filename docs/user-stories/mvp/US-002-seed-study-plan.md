# US-002 — Seed the current study plan

- **Epic:** Curriculum
- **Size:** M
- **Depends on:** US-001
- **Status:** Backlog

## Story

As a **student**, I want **the real study plan of my career loaded in the app**, so that **I see my actual subjects and prerequisites**.

## Rules and notes

- Source of truth: the official plan document. Data lives in versioned files (`db/seeds/plans/<year>.yml`)
  and is loaded by `db/seeds.rb` idempotently.
- Creates `Career`, `StudyPlan`, `Subject` (name, code, year, term, hours/credits) and course `Prerequisite` rows.
- Start with **one** plan (the current one). Other plans arrive later through the same format.
- Validation: no prerequisite cycles; a subject cannot require itself.

## Out of scope

- Admin UI, CSV import, equivalences, final-exam and count-based prerequisites.

## Acceptance criteria

Target file: `features/curriculum/seed_study_plan.feature`

```gherkin
@curriculum @US-002
Feature: Seeded study plan
  Scenario: The seeds create a consistent plan
    Given the seed data is loaded
    Then the career has a study plan for the current year
    And every subject belongs to a year and a term
    And no subject is its own prerequisite

  Scenario: Seeds can be loaded twice
    Given the seed data is loaded
    When the seed data is loaded again
    Then no duplicate subjects exist
```

## Technical notes

- Models `Career`, `StudyPlan`, `Subject`, `Prerequisite`; unique indexes on (plan, code).
- Loader as a plain Ruby service object (`Seeds::PlanLoader`) with RSpec coverage.
