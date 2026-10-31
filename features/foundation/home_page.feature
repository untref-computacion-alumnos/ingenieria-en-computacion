@foundation @US-001
Feature: Home page
  As a visitor
  I want to see the application name and tagline on the home page
  So that I know what the application is

  Scenario: A visitor opens the home page
    When I visit the home page
    Then I should see the application name
    And I should see the home tagline
