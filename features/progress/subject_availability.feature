@progress @US-12
Feature: Subject availability
  As a student
  I want each subject marked as available or blocked
  So that I know what I can take next

  Background:
    Given the study plan "2018" has the subject "Álgebra"
    And the subject "Geometría" of the plan requires "Álgebra"
    And I am signed in as a student following the plan "2018"

  Scenario: A subject is blocked until its prerequisite is met
    When I look at the grid
    Then the subject "Geometría" should show as blocked

  Scenario: A subject becomes available
    Given I marked the subject "Álgebra" as regular
    When I look at the grid
    Then the subject "Geometría" should show as available

  Scenario: A blocked subject cannot be started
    When I try to mark the subject "Geometría" as in progress
    Then I should see which prerequisites are missing

  @javascript
  Scenario: Passing a prerequisites unlocks the next subject without reloading
    Given I opened the subject "Álgebra" from the grid
    When I set the subject as regular
    Then the card of "Geometría" should show as available
    And the page should not have been reloaded
