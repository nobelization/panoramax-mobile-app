Feature: Panoramax mobile App

  Scenario: Homepage
    Given the app is running
    Then I should see a title named {'Your sequences'}
    And I should see a button named {'Create a new sequence'}

  Scenario: Capture page
    Given the app is running
    When I tap on a button named {'Create a new sequence'}
    Then I should see a button named {'Create a new sequence with captured pictures'}