require 'minitest/autorun' # 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_service'

# Tests for the TaskService
class TestTaskService < Minitest::Test # Test::Unit::TestCase

  context "TaskService" do
    # Creates a TaskService object used in each shoulda
    setup do
      backup_system_files("TestTaskService")
      @service = Syctask::TaskService.new
    end

    # Removes files and directories created by the tests
    teardown do
      restore_system_files("TestTaskService")
      FileUtils.rm_r "test/tasks" if File.exists? "test/tasks"
    end

    should "save task with id 1" do
      options = {d: "2013-02-20", f: "2013-02-19", description: "Description"}
      @service.create("test/tasks", options, "This is a new task")
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/1.task" 
    end

    should "save each task with individual id" do
      @service.create("test/tasks", {}, "Task with id 1")
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/1.task"
      @service.create("test/tasks", {}, "Task with id 2")
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/2.task"
      assert_equal 2, Dir.glob("test/tasks/*").size
    end

    should "save task with non task in task directory" do
      @service.create("test/tasks", {}, "This is again a task")
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/1.task"
    end

    should "find task with id 1" do
      @service.create("test/tasks", {d: "2013-02-19"}, "This is another task")
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/1.task"
      filter = {id: "1"}
      refute_empty @service.find("test/tasks", filter)
      assert_equal @service.find("test/tasks", filter)[0].id, 1
    end

    should "find tasks with id 1, 2 and 3" do
      @service.create("test/tasks", {}, "This is the first task")
      @service.create("test/tasks", {}, "This is the second task")
      @service.create("test/tasks", {}, "This is the third task")
      filter = {id: "1,2"}
      assert_equal 2, @service.find("test/tasks", filter).size
      filter = {id: "<3"}
      assert_equal 2, @service.find("test/tasks", filter).size
      filter = {id: ">2"}
      assert_equal 1, @service.find("test/tasks", filter).size
      filter = {id: "=2"}
      assert_equal 1, @service.find("test/tasks", filter).size
    end

    should "find task with non tasks in task directory" do
      @service.create("test/tasks", {}, "This is a task")
      FileUtils.touch "test/tasks/no_task"
      FileUtils.mkdir "test/tasks/directory"
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/1.task"
      filter = {id: "1"}
      refute_empty @service.find("test/tasks", filter)
    end

    should "update task" do
      @service.create("test/tasks", {}, "This is a task to update")
      @service.update("test/tasks", 1, {f: "2013-02-22", n: "Requested help"})
      refute_empty @service.find("test/tasks", {f: "2013-02-22", id: "1"})
    end

    should "mark task as done and don't show in find" do
      @service.create("test/tasks", {}, "This is task one")
      @service.create("test/tasks", {}, "This is task two")
      @service.create("test/tasks", {}, "This is task three")
      task = @service.read("test/tasks", 1)
      task.done("Finalize task")
      @service.save("test/tasks", task)
      assert_equal 2, @service.find("test/tasks", {}, false).size
      assert_equal 3, @service.find("test/tasks").size
    end

    should "delete tasks" do
      @service.create("test/tasks", {}, "Task one")
      @service.create("test/tasks", {}, "Task two")
      @service.create("test/tasks", {}, "Task three")
      tasks = @service.find("test/tasks")
      ids = []
      tasks.each {|task| ids << task.id}
      deleted = @service.delete("test/tasks", {id: ids.join(',')})
      assert_equal tasks.size, deleted
    end
  end

end
