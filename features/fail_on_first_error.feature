Feature: fail on first error
  In order to get feedback sooner
  I can opt out of running the whole sweet if there is a problem

  @announce
  Scenario:
    Given a cucumber suite with two features that each fail
    When I run flatware with "--fail-fast"
    Then I see that 1 scenario was run
    And the failure list only includes one feature

  Scenario: failing fast is faster
    Given two features that will fail slowly
    When I time the suite with fail-fast
    And I time the suite with flatware
    Then fail-fast is the fastest
