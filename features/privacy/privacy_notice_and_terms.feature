@privacy @US-15
Feature: Privacy notice and terms
  As a visitor or student
  I want to read what data is stored and how it is used
  So that I can decide to trust the app

  Scenario: Anyone can read the notice and terms
    When I visit the privacy page
    Then I should see the privacy notice
    When I visit the terms page
    Then I should see the terms

  Scenario: Sign-up requires accepting the terms
    When I sign up without accepting the terms
    Then I should see an error about accepting the terms
    And I should not be signed in
