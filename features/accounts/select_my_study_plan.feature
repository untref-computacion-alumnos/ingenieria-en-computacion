@accounts @US-10
Feature: Select my study plan
  As a student
  I want to choose which study plan I follow
  So that I see my own grid and my progress

  Background:
    Given the study plans "2011" and "2018" exist
    And I am signed in as a student without a plan

  Scenario: A student without a plan is asked to choose one
    When I visit the home page
    Then I should be asked to choose my study plan

  Scenario: A student chooses a plan
    When I choose the plan "2018"
    Then my plan should be "2018"
    And I should see the grid of "2018"
