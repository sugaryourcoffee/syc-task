Feature: My bootstrapped app kinda works
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Scenario: App just runs
    When I get help for "syctask"
    Then the exit status should be 0

  Scenario: Add a new task
    Given no task is available in "~/.tasks"
    When I run `syctask new "Some new task"`
    Then a task should be in "~/.tasks"

  Scenario: Add a new task with prio 1 and 2 tags
    Given no task is available in "~/.tasks"
    When I run `syctask new "Some new task" -p 1 -t meeting,preparation`
    Then a task should be in "~/.tasks"
    And the task should contain prio "1" and tags "meeting,preparation"

  Scenario: Add a new task with all parameters
    Given no task is available in "~/.tasks"
    When I run `syctask new "Some new task" -p 1 -t meeting -f 2013-02-16 -d 2013-02-28 -n "The description of the task"`
    Then a task should be in "~/.tasks"
    And the task should contain prio "1" a tag "meeting" a follow-up date "2013-02-16" a due date "2013-02-28" a description "The description of the task" and a note "Just added the new task"

