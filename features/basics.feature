Feature: options, help and misc edge cases

  Scenario Outline: Print help
    When I run "<command>"
    Then the output should contain "one9 [OPTIONS] COMMAND"

    Examples:
      | command     |
      | one9        |
      | one9 -h     |
      | one9 --help |

  Scenario Outline: Print version
    When I run "<command>"
    Then the output contains the current version

    Examples:
      | command        |
      | one9 -v        |
      | one9 --version |

  Scenario: Print error for invalid option
    When I run "one9 -z"
    Then the stderr should contain "one9: invalid option `-z'"

  Scenario: Print error for invalid command
    When I run "one9 blah"
    Then the output should match /^one9: Invalid command `blah'/
    And the exit status should be 1

  Scenario Outline: Print command help
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
