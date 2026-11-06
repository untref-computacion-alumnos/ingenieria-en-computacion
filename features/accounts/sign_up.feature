@accounts @US-07
Feature: Sign up
  As a visitor
  I want to create an account with my email and a password
  So that my progress can be saved

  Scenario: A visitor creates an account
    When I sign up with a valid email and password
    Then I should be signed in
    And I should have the student role

  Scenario: An email already in use is rejected
    Given a user exists with the email "ana@example.com"
    When I sign up with the email "ana@example.com"
    Then I should see an error about the email being taken
    And I should not be signed in
