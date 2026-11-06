@curriculum @javascript @US-06 @wip
Feature: Highlight prerequisites
  As a visitor
  I want related subjects highlighted when I select a subject
  So that I see what it requires and what it unlocks without opening each one

  Background:
    Given the subject "Álgebra II" requires "Álgebra I" and unlocks "Análisis II"

  Scenario: Selecting a subject highlights what it needs and unlocks
    When I select the subject "Álgebra II" in the grid
    Then "Álgebra I" should be highlighted as a prerequisite
    And "Análisis II" should be highlighted as unlocked

  Scenario: Selecting again clears the highlight
    Given I selected the subject "Álgebra II" in the grid
    When I select the subject "Álgebra II" in the grid
    Then no subject should be highlighted
