@accounts @US-08
Feature: Log in and out
  As a student
  I want to log in and out
  So that only I can see and change my progress

  Scenario: A student logs in
    Given a registered student
    When I log in with the right credentials
    Then I should be signed in

  Scenario: Wrong credentials are rejected
    Given a registered student
    When I log in with a wrong password
    Then I should see the invalid credentials message
    And I should not be signed in

  Scenario: A student logs out
    Given I am signed in as a student
    When I log out
    Then I should not be signed in
