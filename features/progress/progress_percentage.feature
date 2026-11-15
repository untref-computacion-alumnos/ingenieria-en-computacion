@progress @US-13
Feature: Progress percentage
  As a student
  I want to see how much of my degree I have completed
  So that I feel progress and know what is left

  Scenario: A student sees their progress
    Given I am signed in as a student following a plan with 40 subjects
    And I have 10 subjects approved and 2 promoted
    When I look at the grid
    Then I should see 12 of 40 subjects completed
    And I should see 30 percent

  Scenario: A new student has no progress
    Given I am signed in as a student following a plan with 40 subjects
    When I look at the grid
    Then I should see 0 of 40 subjects completed

  @javascript
  Scenario: Approving a subject updates the progress without reloading
    Given I am signed in as a student following a plan with 4 subjects
    And I opened the first subject of the plan from the grid
    When I set the subject as approved
    Then I should see 1 of 4 subjects completed
    And I should see 25 percent
    And the page should not have been reloaded
