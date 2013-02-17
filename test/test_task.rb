require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task'

class TestTask < Test::Unit::TestCase

  context "Task" do

    should "create task with title" do
      task = SycTask::Task.new("test/tasks/", {}, "Some new task")
      assert_equal 1, task.id
      assert_equal "Some new task", task.title
    end

    should "update existing attribute in task" do
      task = SycTask::Task.new("test/tasks/", {d: "2013-02-17"}, "Some task")
      assert_equal "2013-02-17", task.options[:d]
      options = {d: "2013-02-27"}
      task.update(options)
      assert_equal "2013-02-27", task.options[:d]
    end

    should "update task with inexistent attribute" do
      task = SycTask::Task.new("test/tasks/", {}, "Some task")
      assert_nil task.options[:d]
      options = {d: "2013-02-28", f: "2013-02-18"}
      task.update(options)
      assert_equal "2013-02-28", task.options[:d]
      assert_equal "2013-02-18", task.options[:f]
    end

    should "add note to task's existing note" do

    end

    should "add tag to task's existing tags" do

    end

    should "override task's existing tags" do

    end

    should "pretty print the task" do

    end

    should "raw print the task" do

    end
  end
end
