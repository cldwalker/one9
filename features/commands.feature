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

  Scenario: edit command with unsupported editor
    Given I have a report
    And I have the editor "nano"
    When I run "one9 edit"
    Then the output should contain "No support for nano yet. Patches welcome :)"

  Scenario: edit command with supported editor
    Given I have a report
    And I have the editor "vim"
    When I run "one9 edit" which hangs
    Then the output should contain ""

  Scenario: test command with arguments
    Given I have a report
    When I run "one9 test ruby -e 'puts'"
    Then the output should contain "** One9 Report **"
    And the output should not contain multiple reports

  Scenario: test command with no arguments
    Given I have a report
    And a file named "Rakefile" with:
      | task(:test) { sh %[ruby -e 'puts "OK"'] } |
    When I run "one9 test"
    Then the output should contain "** One9 Report **"
    And the output should not contain multiple reports
