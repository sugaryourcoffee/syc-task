require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task'

class TestTask < Test::Unit::TestCase

  context "Task" do

    should "create task with title" do
      task = Syctask::Task.new({}, "Some new task", 1)
      assert_equal 1, task.id
      assert_equal "Some new task", task.title
    end

    should "update existing attribute in task" do
      task = Syctask::Task.new({d: "2013-02-17"}, "Some task", 1)
      assert_equal "2013-02-17", task.options[:d]
      options = {d: "2013-02-27"}
      task.update(options)
      assert_equal "2013-02-27", task.options[:d]
    end

    should "update task with inexistent attribute" do
      task = Syctask::Task.new({}, "Some task", 1)
      assert_nil task.options[:d]
      options = {d: "2013-02-28", f: "2013-02-18"}
      task.update(options)
      assert_equal "2013-02-28", task.options[:d]
      assert_equal "2013-02-18", task.options[:f]
    end

    should "add note to task's existing note" do
      task = Syctask::Task.new({n: "This is my first note"}, "Some task", 1)
      assert_match /This is my first note/, task.options[:n]
      options = {n: "And this is my second note"}
      task.update(options)
      assert_match /And this is my second note/, task.options[:n]
    end

    should "add tag to task's existing tags" do
      task = Syctask::Task.new({t: "presentation,workshop"}, "Some task", 1)
      assert_equal "presentation,workshop", task.options[:t]
      options = {t: "customer"}
      task.update(options)
      refute_nil task.update_date
      assert_equal "presentation,workshop,customer", task.options[:t]
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
      assert_match "Finalize task", task.options[:n]
    end

    should "pretty print the task" do
      options = {f: "2013-02-28", d: "2013-03-15", p: 2,
                 description: "This is a description of the task",
                 n: "This is a note on the task",
                 t: "presentation,workshop"}
      task = Syctask::Task.new(options, "Some new task", 1)
      task.print_pretty
    end

    should "pretting print all fields of the task" do
      options = {f: "2013-02-28", d: "2013-03-15", p: 2,
                 description: "This is all of the description of the task",
                 n: "This is a long note\nthat is over more\nthan on line",
                 t: "presentation,work"}
      task = Syctask::Task.new(options, "Some long new task", 12)
      task.print_pretty(true)
      options = {n: "This is another note for a very long task, that has been\nwritten over more than one line.\nBut this is not neccessarily good"}
      task.update(options)
      task.print_pretty(true)
      task.done("This is the end of the task")
      task.print_pretty(true)
    end

    should "print the task as csv" do
      options = {f: "2013-02-28", d: "2013-03-15", p: 2,
                 description: "This is a description of the task",
                 n: "This is a note on the task",
                 t: "presentation,workshop"}
      task = Syctask::Task.new(options, "Some new task", 1)
      task.print_csv
    end
  end
end
