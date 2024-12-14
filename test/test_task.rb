require 'minitest/autorun' # 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task'

# Tests for the Task
class TestTask < Minitest::Test # Test::Unit::TestCase

  context "Task" do

    # Backup system files
    def setup
      backup_system_files("TestTask")
    end

    # Restore system files
    def teardown
      restore_system_files("TestTask")
    end

    should "create task with title" do
      task = Syctask::Task.new({}, "Some new task", 1)
      assert_equal 1, task.id
      assert_equal "Some new task", task.title
    end

    should "update existing attribute in task" do
      task = Syctask::Task.new({due: "2013-02-17"}, "Some task", 1)
      assert_equal "2013-02-17", task.options[:due]
      options = {due: "2013-02-27"}
      task.update(options)
      assert_equal "2013-02-27", task.options[:due]
    end

    should "update task with inexistent attribute" do
      task = Syctask::Task.new({}, "Some task", 1)
      assert_nil task.options[:due]
      options = {due: "2013-02-28", follow_up: "2013-02-18"}
      task.update(options)
      assert_equal "2013-02-28", task.options[:due]
      assert_equal "2013-02-18", task.options[:follow_up]
    end

    should "add note to task's existing note" do
      task = Syctask::Task.new({note: "This is my first note"}, "Some task", 1)
      assert_match (/This is my first note/), task.options[:note]
      options = {note: "And this is my second note"}
      task.update(options)
      assert_match (/And this is my second note/), task.options[:note]
    end

    should "add tag to task's existing tags" do
      task = Syctask::Task.new({tags: "presentation,workshop"}, "Some task", 1)
      assert_equal "presentation,workshop", task.options[:tags]
      options = {tags: "customer"}
      task.update(options)
      refute_nil task.update_date
      assert_equal "presentation,workshop,customer", task.options[:tags]
    end

    should "mark task as done" do
      task = Syctask::Task.new("Some task", 1)
      task.done
      refute_nil task.done_date
    end

    should "mark task as done and add note" do
      task = Syctask::Task.new("Some task", 1)
      task.done("Finalize task")
      refute_nil task.done_date
      assert_match "Finalize task", task.options[:note]
    end

    should "pretty print the task" do
      options = {follow_up: "2013-02-28", due: "2013-03-15", prio: 2,
                 description: "This is a description of the task",
                 note: "This is a note on the task",
                 tags: "presentation,workshop"}
      task = Syctask::Task.new(options, "Some new task", 1)
      task.print_pretty
    end

    should "pretting print all fields of the task" do
      options = {follow_up: "2013-02-28", d: "2013-03-15", p: 2,
                 description: "This is all of the description of the task",
                 note: "This is a long note\nthat is over more\nthan on line",
                 tags: "presentation,work"}
      task = Syctask::Task.new(options, "Some long new task", 12)
      task.print_pretty(true)
      options = {note: "This is another note for a very long task, that has been\nwritten over more than one line.\nBut this is not neccessarily good"}
      task.update(options)
      task.print_pretty(true)
      task.done("This is the end of the task")
      task.print_pretty(true)
    end

    should "print the task as csv" do
      options = {follow_up: "2013-02-28", d: "2013-03-15", p: 2,
                 description: "This is a description of the task",
                 note: "This is a note on the task",
                 tags: "presentation,workshop"}
      task = Syctask::Task.new(options, "Some new task", 1)
      task.print_csv
    end
  end
end
