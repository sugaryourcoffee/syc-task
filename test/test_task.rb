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
  end
end
