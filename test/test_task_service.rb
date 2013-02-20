require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_service'

class TestTaskService < Test::Unit::TestCase

  context "TaskService" do
    should "save task with id 1" do
      options = {d: "2013-02-20", f: "2013-02-19", description: "Description"}
      service = Syctask::TaskService.new
      service.create("test/blub", options, "This is a new task")
      
    end

    should "read task with id 1" do
    end

    should "update task" do
    end

  end

end
