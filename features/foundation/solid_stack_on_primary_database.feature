@foundation @US-001.5
Feature: Solid stack on primary database
  As a developer
  I want Solid Queue, Solid Cache and Solid Cable to use the primary database
  So that the application boots on a hosting that offers a single database

  Scenario: The background tables lives in the primary database
    When I list the tables of the primary database
    Then the list includes the Solid Queue tables
    And the list includes the Solid Cache table
    And the list includes the Solid Cable table
