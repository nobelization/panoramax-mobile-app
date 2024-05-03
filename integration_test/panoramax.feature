Feature: Panoramax mobile App

  Scenario: Homepage
    Given the app is running with locale {'en'}
    Then I should see a title named {'Your sequences'}
    And I should see a button named {'Create a new sequence'}

  Scenario: Capture page should be disabled in portrait mode
    Given I put the device in portrait mode
    And the app is running with locale {'en'}
    When I tap on a button named {'Create a new sequence'}
    Then I should see the text {'Turn your phone to start capturing images'}

  Scenario: Capture page should be enabled in landscape mode
    Given I put the device in landscape mode
    And the app is running with locale {'en'}
    When I tap on a button named {'Create a new sequence'}
    Then I should see a button named {'Take a picture'}
