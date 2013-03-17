require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_tracker.rb'
require_relative '../lib/syctask/task_service.rb'

# Tests for TaskTracker
class TestTaskTracker < Test::Unit::TestCase

  context "TaskTracker" do

    def setup
      @origin = Syctask::TaskTracker::TRACKED_TASKS_FILE
      @copy = @origin + '.copy'
      FileUtils.mv @origin, @copy if File.exists? @origin
      @dir = 'test/tasks'
      @service = Syctask::TaskService.new
      @ids = []
      1.upto(5) do |i|
        @ids << @service.create(@dir, {}, "Task number #{i}") 
      end
    end

    def teardown
      FileUtils.mv @copy, @origin if File.exists? @copy
      FileUtils.rm_r @dir if File.exists? @dir
    end

    should "create task tracker" do
      tracker = Syctask::TaskTracker.new
      assert tracker.start(@service.read @dir, @ids[0])
      refute tracker.start(@service.read @dir, @ids[0])
      assert_equal 0, tracker.stop.size
    end

  end

end
