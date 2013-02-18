require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task'

class TestTask < Test::Unit::TestCase

  context "Task" do

    should "create task with title" do
      task = SycTask::Task.new({}, "Some new task", 1)
      assert_equal 1, task.id
      assert_equal "Some new task", task.title
    end

    should "update existing attribute in task" do
      task = SycTask::Task.new({d: "2013-02-17"}, "Some task", 1)
      assert_equal "2013-02-17", task.options[:d]
      options = {d: "2013-02-27"}
      task.update(options)
      assert_equal "2013-02-27", task.options[:d]
    end

    should "update task with inexistent attribute" do
      task = SycTask::Task.new({}, "Some task", 1)
      assert_nil task.options[:d]
      options = {d: "2013-02-28", f: "2013-02-18"}
      task.update(options)
      assert_equal "2013-02-28", task.options[:d]
      assert_equal "2013-02-18", task.options[:f]
    end

    should "add note to task's existing note" do
      task = SycTask::Task.new({n: "This is my first note"}, "Some task", 1)
      assert_match /This is my first note/, task.options[:n]
      options = {n: "And this is my second note"}
      task.update(options)
      assert_match /And this is my second note/, task.options[:n]
    end

    should "add tag to task's existing tags" do
      task = SycTask::Task.new({t: "presentation,workshop"}, "Some task", 1)
      assert_equal "presentation,workshop", task.options[:t]
      options = {t: "customer"}
      task.update(options)
      refute_nil task.update_date
      assert_equal "presentation,workshop,customer", task.options[:t]
    end

    should "override task's existing tags" do

    end

    should "mark task as done" do
      task = SycTask::Task.new("Some task", 1)
      task.done
      refute_nil task.done_date
    end

    should "mark task as done and add note" do
      task = SycTask::Task.new("Some task", 1)
      task.done("Finalize task")
      refute_nil task.done_date
    end

    should "pretty print the task" do
      options = {f: "2013-02-28", d: "2013-03-15", p: 2,
                 description: "This is a description of the task",
                 n: "This is a note on the task",
                 t: "presentation,workshop"}
      task = SycTask::Task.new(options, "Some new task", 1)
      task.print_pretty
    end

    should "print the task as csv" do
      options = {f: "2013-02-28", d: "2013-03-15", p: 2,
                 description: "This is a description of the task",
                 n: "This is a note on the task",
                 t: "presentation,workshop"}
      task = SycTask::Task.new(options, "Some new task", 1)
      task.print_csv
    end
  end
end
