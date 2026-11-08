@accounts @US-09
Feature: Reset password
  As a student
  I want to reset my password by email
  So that I can recover my account if I forget it

  Scenario: A student asks for a reset link
    Given a registered student
    When I request a password reset for their email
    Then a reset email should be sent to them

  Scenario: A student sets a new password
    Given a registered student with a reset link
    When I follow the link and set a new password
    Then I should be able to log in with the new password

  Scenario: An unknown email gives the same answer
    When I request a password reset for an unknown email
    Then I should see the same confirmation message
    And no email should be sent
