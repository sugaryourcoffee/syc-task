Feature: My bootstrapped app kinda works
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Scenario: App just runs
    When I get help for "syctask"
    Then the exit status should be 0

  Scenario: ENV['HOME'] should point to '/tmp/fake_home'
    When I run `ruby -e "puts ENV['HOME']"`
    Then the stdout should contain "/tmp/fake_home"

  Scenario: Add a new task
    Given no task is available in the default task directory
    When I run `syctask new "Some new task"`
    Then a task should be in the default task directory

  Scenario: Add a new task with prio 1 and 2 tags
    Given no task is available in the default task directory
    When I successfully run `syctask new "Some new task" -p 1 -t meeting,preparation`
    Then a task should be in the default task directory
    When I successfully run `syctask list -c`
    And the stdout should contain "1"
    And the stdout should contain "meeting,preparation"

  Scenario: Add a new task with all parameters
    Given no task is available in the default task directory
    When I run `syctask new "Some new task" -p 1 -t meeting -f 2013-02-16 -d 2013-02-28 -n "The description of the task"`
    Then a task should be in the default task directory
    When I run `syctask list --csv`
    Then the stdout should contain "Some new task"
    And the stdout should contain "1"
    And the stdout should contain "meeting"
    And the stdout should contain "2013-02-16"
    And the stdout should contain "2013-02-28"
    And the stdout should contain "The description of the task"
    And the stdout should contain "UNCHANGED;OPEN"

