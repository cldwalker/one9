Feature: Commands

  Scenario Outline: Commands print help
    When I run "one9 <command> -h"
    Then the output should contain "one9 <usage>"

    Examples:
      | command  | usage                        |
      | test     | test [COMMAND='rake test']   |
      | list     | list [QUERY] [-a\|--all]     |
      | edit     | edit [QUERY]                 |
      | changes  | changes [QUERY]              |
      | lines    | lines [QUERY] [-a\|--all]    |
      | quickfix | quickfix [QUERY] [-a\|--all] |

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

  Scenario Outline: Commands with -a option print all changes
    Given I have a report
    When I run "one9 <command> -a"
    Then the output should contain "Module#public_m"

    Examples:
      | command  |
      | list     |
      | quickfix |
      | lines    |

  Scenario Outline: Commands with queries return correct results
    Given I have a report
    When I run "one9 <command> Hash"
    Then the output should contain "Hash"
    And the output should not contain "Module"

    Examples:
      | command  |
      | list     |
      | quickfix |
      | lines    |
      | changes  |

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
    When I run "one9 test ruby -e 'puts'"
    Then the output should contain "** One9 Report **"
    And the output should not contain multiple reports

  Scenario: test command with no arguments
    Given a file named "Rakefile" with:
      | task(:test) { sh %[ruby -e 'puts "OK"'] } |
    When I run "one9 test"
    Then the output should contain "** One9 Report **"
    And the output should not contain multiple reports

  Scenario: changes command with rc file
    Given I have a rc file
    When I run "one9 changes"
    Then the output contains all default methods
    And the output should contain "Module#stub"

  Scenario: changes command with no rc file
    Given I have no rc file
    When I run "one9 changes"
    Then the output contains all default methods

  Scenario: list command with valid data
    Given I have a report
    When I run "one9 list"
    Then the output should contain "** One9 Report **"
    And the output should contain "Hash#select"
    And the output should contain "4 rows in set"

  Scenario: list command with invalid data
    Given I have an invalid report
    When I run "one9 list"
    Then the stderr should contain "one9 error: marshal"

  Scenario: list command with no data
    Given I have a report with no data
    When I run "one9 list"
    Then the output should contain "No 1.9 changes found"
