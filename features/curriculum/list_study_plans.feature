@curriculum @US-010 @wip
Feature: List study plans
  As a visitor
  I want to see the available study plans of the career
  So that I can open the one that applies to me

  Scenario: A visitor sees the available plans
    Given the study plans "2013" and "2022" exist
    When I visit the study plans page
    Then I should see the plans "202" and "2013" in that order
    And the plan "2022" should be marked as the active plan
