Feature: Scanning tasks from a file
  The user has created a minutes of meetings where tasks are listed. The tasks
  are annotated with @task for following single task to be scanned or @tasks
  for multiple tasks to be scanned until the first blank line. If a line starts
  with a '-' it is ignored. Each task field is spearated by a separator that is 
  part of the annotation. If the separator is a ';' then the annotation is 
  '@task;'. The order of the fields have to be in a specific. Missing fields 
  have to be enclosed between 2 spearators.

  Specifying the field order
  --------------------------
  '@task;
  title;follow-up;due-date;prio;description

  Example:
  =======
  '@tasks;
  title;description;follow-up;due-date;prio
  title1;description of title1;2016-09-20;2016-09-21;3
  title2;;2016-09-20

  We could also create this in a markdown table

  '@tasks|
  Title   | Description            | Follow-up  | Due        | Prio
  ------- | ---------------------- | ---------- | ---------- | ----
  Title 1 | Description of Title 1 | 2016-09-20 | 2016-09-21 | 1
  Title 2 |                        | 2016-09-20 |            |

Scenario: Scan a file with all fields set
    Given the task directory "/tmp/test-tasks/" doesn't exist
    And I have a file "/tmp/mom.md" file with "3" tasks and all fields set
    When I run `syctask -f /tmp/test_tasks/ scan /tmp/mom.md` 
    Then the directory "/tmp/test-tasks/" should contain "3" tasks

