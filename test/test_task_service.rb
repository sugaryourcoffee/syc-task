require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_service'

class TestTaskService < Test::Unit::TestCase

  def setup
    @service = Syctask::TaskService.new
  end

  def teardown
    FileUtils.rm_r "test/tasks" if File.exists? "test/tasks"
  end

  context "TaskService" do
    should "save task with id 1" do
      options = {d: "2013-02-20", f: "2013-02-19", description: "Description"}
      service = Syctask::TaskService.new
      service.create("test/tasks", options, "This is a new task")
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/1.task" 
    end

    should "save each task with individual id" do
      service = Syctask::TaskService.new
      service.create("test/tasks", {}, "Task with id 1")
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/1.task"
      service.create("test/tasks", {}, "Task with id 2")
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

    should "find tasks with id 1 and 2" do
      @service.create("test/tasks", {}, "This is the first task")
      @service.create("test/tasks", {}, "This is the second task")
      @service.create("test/tasks", {}, "This is the third task")
      filter = {id: "1,2"}
      assert_equal 2, @service.find("test/tasks", filter).size
      puts "now we are talking about the topic"
      filter = {id: "<3"}
      assert_equal 2, @service.find("test/tasks", filter).size
    end

    should "find task with non tasks in task directory" do
      @service.create("test/tasks", {}, "This is a task")
      FileUtils.touch "test/tasks/no_task"
      assert_contains Dir.glob("test/tasks/*"), "test/tasks/1.task"
      filter = {id: "1"}
      refute_empty @service.find("test/tasks", filter)
    end

    should "update task" do
      @service.create("test/tasks", {}, "This is a task to update")
      @service.update("test/tasks", 1, {f: "2013-02-22", n: "Requested help"})
      refute_empty @service.find("test/tasks", {f: "2013-02-22", id: "1"})
    end

  end

end
