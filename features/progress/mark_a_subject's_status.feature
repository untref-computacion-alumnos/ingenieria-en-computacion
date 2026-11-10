@progress @US-11
Feature: Mark a subject's status
  As a student
  I want to set the status of each subject
  So that the grid reflects where I am

  Background:
    Given the study plan "2018" has the subject "Álgebra I"

  Scenario: Marking a subject as in progress
    Given I am signed in as a student following the plan "2018"
    When I mark the subject "Álgebra I" as in progress
    Then the subject "Álgebra I" should show as in progress

  Scenario: Changing a status
    Given I am signed in as a student following the plan "2018"
    And I marked the subject "Álgebra I" as regular
    When I mark the subject "Álgebra I" as approved
    Then the subject "Álgebra I" should show as approved

  Scenario: A visitor is asked to sign in
    When I try to mark the subject "Álgebra I" as approved
    Then I should be asked to sign in

  @javascript
  Scenario: The grid updates without reloading the page
    Given I am signed in as a student following the plan "2018"
    And I opened the subject "Álgebra I" from the grid
    When I set the subject as approved
    Then the card of "Álgebra I" should show as approved
    And the page should not have been reloaded
