@curriculum @US-002 @wip
Feature: Seed study plan
  As a student
  I want the real study plan of my career loaded in the app
  So that I see my actual subjects and prerequisites

  Scenario: The seeds create a consistent plan
    When the seed data is loaded
    Then the career has a study plan for the current year
    And every subject belongs to a year and a term
    And no subject is its own prerequisite

  Scenario: Seeds can be loaded twice
    When the seed data is loaded twice
    Then no duplicate subjects exist
