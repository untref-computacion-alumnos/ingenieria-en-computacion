@curriculum @US-05
Feature: Subject detail
  As a visitor
  I want to open a subject and see its details and prerequisites
  So that I know what it requires and how heavy it is

  Scenario: A visitor opens a subject from the grid
    Given the subject "Álgebra II" requires "Álgebra I"
    When I open the subject "Álgebra II" from the grid
    Then I should see the subject details
    And I should see "Álgebra I" listed as a prerequisite

  @allow-rescue
  Scenario: An unknown subject is not found
    When I open a subject that does not exist
    Then I should see the not found page
