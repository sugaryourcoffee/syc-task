require 'minitest/autorun' # 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_tracker.rb'
require_relative '../lib/syctask/task_service.rb'

# Tests for TaskTracker
class TestTaskTracker < Minitest::Test # Test::Unit::TestCase

  context "TaskTracker" do

    # Create variables and tasks for tests
    setup do
      backup_system_files("TestTaskTracker")
      @origin = Syctask::TaskTracker::TRACKED_TASKS_FILE
      @copy = @origin + '.copy'
      FileUtils.mv @origin, @copy if File.exist? @origin
      @dir = 'test/tasks'
      @service = Syctask::TaskService.new
      @ids = []
      1.upto(5) do |i|
        @ids << @service.create(@dir, {}, "Task number #{i}") 
      end
    end

    # Remove created files and directories during tests
    teardown do
      restore_system_files("TestTaskTracker")
      FileUtils.mv @copy, @origin if File.exist? @copy
      FileUtils.rm_r @dir if File.exist? @dir
    end

    should "create task tracker" do
      tracker = Syctask::TaskTracker.new

      result = tracker.start(@service.read @dir, @ids[0])
      assert_equal [true, nil], result
      
      result = tracker.start(@service.read @dir, @ids[0])
      assert_equal [false, nil], result

      refute_nil tracker.stop

      result = tracker.start(@service.read @dir, @ids[1])
      assert_equal [true, nil], result

      refute_nil tracker.tracked_task

      result = tracker.start(@service.read @dir, @ids[2])
      assert result[0]
      refute_nil result[1]

      refute_nil tracker.stop

      assert_nil tracker.tracked_task

    end

  end

end
