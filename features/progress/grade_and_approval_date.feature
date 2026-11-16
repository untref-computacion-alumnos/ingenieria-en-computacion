@progress @US-14
Feature: Grade and approval date
  As a student
  I want to save the grade and date when I approve or promote a subject
  So that I keep my academic record in one place

  Background:
    Given the study plan "2018" has the subject "Álgebra I"
    And I am signed in as a student following the plan "2018"
    And I marked the subject "Álgebra I" as approved

  Scenario: Saving a grade and date
    When I save the grade 8 and the date "2024-12-10" for "Álgebra I"
    Then the subject "Álgebra I" should show grade 8 and that date

  Scenario: An invalid grade is rejected
    When I save the grade 11 for "Álgebra I"
    Then I should see an error about the grade

  Scenario: A future date is rejected
    When I save a date in the future for "Álgebra I"
    Then I should see an error about the date
