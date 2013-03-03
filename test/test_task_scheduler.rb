require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_scheduler.rb'

class TestTaskScheduler < Test::Unit::TestCase

  context "TaskScheduler" do
    def setup
    end

    def teardown
    end

    should "create new TaskScheduler" do
      work_time = "8:30-18:30"
      busy_time = "9:00-9:30,10:00-11:45,14:00-15:30"
      assert_nothing_raised(Exception) do
        scheduler = Syctask::TaskScheduler.new(work_time, busy_time)
      end
    end

    should "Scheduler with wrong work and busy time sequence should raise" do
      work_time = "18:30-8:30"
      busy_time = "9:00-9:30,10:00-11:45"
      assert_raise(Exception) do
        scheduler = Syctask::TaskScheduler.new(work_time, busy_time)
      end
      busy_time = "9:00-9:30,10:00-10:00"
      assert_raise(Exception) do
        scheduler = Syctask::TaskScheduler.new(work_time, busy_time)
      end
    end

    should "raise Exception due to empty work time" do
    end

    should "not raise exception due to empty busy time" do
    end

    should "print schedule graph" do
    end

    should "schedule task" do
    end
  end

end
