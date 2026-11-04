@curriculum @US-04 @wip
Feature: View plan grid
  As a visitor
  I want to see a study plan as a grid of subjects by year and term
  So that I understand the whole degree at a glance

  Scenario: Subjects are grouped by year and term
    Given the study plan "2022" has subjects in year 1 term 1 and year 1 term 2
    When I open the study plan "2022"
    Then I should see year 1 term 1 with its subjects
    And I should see year 1 term 2 with its subjects

  @allow-rescue
  Scenario: An unknown plan is not found
    When I open a study plan that does not exist
    Then I should see the not found page
