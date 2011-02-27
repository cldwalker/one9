Feature: Commands

  Scenario Outline: Commands print help
    When I run "one9 <command> -h"
    Then the output should contain "one9 <usage>"

    Examples:
      | command  | usage                      |
      | test     | test [COMMAND='rake test'] |
      | list     | list [QUERY]               |
      | edit     | edit                       |
      | changes  | changes [QUERY]            |
      | lines    | lines [QUERY]              |
      | quickfix | quickfix                   |

  Scenario Outline: Commands print error for no report
    Given I have no report
    When I run "one9 <command>"
    Then the stderr should contain "one9 has no report. `one9 test` your project first."
    And the exit status should be 1

    Examples:
      | command  |
      | list     |
      | edit     |
      | lines    |
      | quickfix |

  Scenario: Edit command with unsupported editor
    Given I have a report
    And I have the editor "nano"
    When I run "one9 edit"
    Then the output should contain "No support for nano yet. Patches welcome :)"
