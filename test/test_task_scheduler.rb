require 'minitest/autorun' # 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_scheduler.rb'

# Tests for the TaskScheduler class
class TestTaskScheduler < Minitest::Test # Test::Unit::TestCase

  context "TaskScheduler" do
    # Sets up the test case and initializes the directory for the test tasks to
    # live
    setup do
      backup_system_files("TestTaskScheduler")
      @dir = "test/tasks"
    end

    # Removes after each test the test task directory
    def teardown
      restore_system_files("TestTaskScheduler")
      FileUtils.rm_r @dir if File.exist? @dir
    end

    should "create new TaskScheduler" do
      work_time = "8:30-18:30"
      busy_time = "9:00-9:30,10:00-11:45,14:00-15:30"
      #assert_nothing_raised(Exception) do
        scheduler = Syctask::TaskScheduler.new
        scheduler.set_work_time(work_time)
        scheduler.set_busy_times(busy_time)
      #end
    end

    should "add work time to log file" do
      work_time = "8:30-18:30"
      scheduler = Syctask::TaskScheduler.new
      scheduler.set_work_time(work_time)
      logs = File.read(Syctask::TASKS_LOG)
      today = Time.now
      begins = Time.local(today.year,today.mon,today.day,8,30,0)
      ends   = Time.local(today.year,today.mon,today.day,18,30,0)
      expected = "work;-1;;work;#{begins};#{ends}"
      assert_equal expected, logs.scan(expected)[0]

      work_time = "8:00-19:15"
      scheduler = Syctask::TaskScheduler.new
      scheduler.set_work_time(work_time)
      logs = File.read(Syctask::TASKS_LOG)
      begins = Time.local(today.year,today.mon,today.day,8,0,0)
      ends   = Time.local(today.year,today.mon,today.day,19,15,0)
      expected_new = "work;-1;;work;#{begins};#{ends}"
      assert_nil logs.scan(expected)[0]
      assert_equal expected_new, logs.scan(expected_new)[0]

      scheduler.set_work_time(work_time)
      logs = File.read(Syctask::TASKS_LOG)
      assert_equal 1, logs.scan(expected_new).size
    end

    should "Meetings to log file" do
      work_time = "8:30-18:30"
      busy_times = "9:00-9:30,10:00-11:00,13:00-14:45"
      scheduler = Syctask::TaskScheduler.new
      scheduler.set_work_time(work_time)
      scheduler.set_busy_times(busy_times)
      logs = File.read(Syctask::TASKS_LOG)
      today = Time.now
      begins = Time.local(today.year,today.mon,today.day,9,00,0)
      ends   = Time.local(today.year,today.mon,today.day,9,30,0)
      expected = "meeting;-2;;Meeting 0;#{begins};#{ends}"
      assert_equal expected, logs.scan(expected)[0]

      busy_times = "10:00-11:15,14:00-18:15"
      scheduler.set_busy_times(busy_times)
      logs = File.read(Syctask::TASKS_LOG)
      begins = Time.local(today.year,today.mon,today.day,10,00,0)
      ends   = Time.local(today.year,today.mon,today.day,11,15,0)
      expected_new = "meeting;-2;;Meeting 0;#{begins};#{ends}"
      assert_nil logs.scan(expected)[0]
      assert_equal expected_new, logs.scan(expected_new)[0]

      meetings = "Status,Workshop"
      scheduler.set_meeting_titles(meetings)
      logs = File.read(Syctask::TASKS_LOG)
      expected = "meeting;-2;;Status;#{begins};#{ends}"
      assert_nil logs.scan(expected_new)[0]
      assert_equal expected, logs.scan(expected)[0]
    end

    should "Scheduler with wrong work and busy time sequence should raise" do
      work_time = "18:30-8:30"
      busy_time = "9:00-9:30,10:00-11:45"
      assert_raises(Exception) do
        scheduler = Syctask::TaskScheduler.new
        scheduler.set_work_time(work_time)
        scheduler.set_busy_times(busy_time)
      end
      busy_time = "9:00-9:30,10:00-10:00"
      assert_raises(Exception) do
        scheduler = Syctask::TaskScheduler.new
        scheduler.set_work_time(work_time)
        scheduler.set_busy_times(busy_time)
      end
    end

    should "raise Exception due to empty work time" do
      work_time = ""
      busy_time = "9:00-10:00"
      assert_raises(Exception) do
        scheduler = Syctask::TaskScheduler.new
        scheduler.set_work_time(work_time)
        scheduler.set_busy_times(busy_time)
      end
    end

    should "not raise exception due to empty busy time" do
      work_time = "8:00-18:00"
      busy_time = ""
      #assert_nothing_raised(Exception) do
        scheduler = Syctask::TaskScheduler.new
        scheduler.set_work_time(work_time)
        scheduler.set_busy_times(busy_time)
      #end
    end

    should "print schedule graph" do
      puts
      work_time = "8:00-18:00"
      busy_time = "9:00-10:00,11:15-12:00,13:30-15:00"
      scheduler = Syctask::TaskScheduler.new
      scheduler.set_work_time(work_time)
      scheduler.set_busy_times(busy_time)
      assert_equal true, scheduler.show
      busy_time = ""
      scheduler.set_busy_times(busy_time)
      assert_equal true, scheduler.show
    end

    should "schedule task" do
      puts
      ids = []
      service = Syctask::TaskService.new
      1..5.times do |i|
        options = {follow_up: Time.now.strftime("%Y-%m-%d")}
        ids << service.create(@dir, options, "Task number #{i+1}")
      end 

      tasks = service.find(@dir, {id: ids.join(',')}, false)
      assert_equal 5, tasks.size

      tasks.each.with_index do |task, index|
        task.set_duration(units_to_time(index + 1))
        service.save(@dir, task)
      end

      work_time = "8:00-18:15"
      busy_time = "8:00-8:20,10:00-11:30,14:15-15:30"
      scheduler = Syctask::TaskScheduler.new
      scheduler.set_work_time(work_time)
      scheduler.set_busy_times(busy_time)
      scheduler.set_tasks(tasks)
      assert scheduler.show
    end

    should "show schedule" do
      work_time = "8:00-18:00"
      busy_time = "8:30-9:00,10:00-11:00,13:00-17:00"
      scheduler = Syctask::TaskScheduler.new
      scheduler.set_work_time(work_time)
      scheduler.set_busy_times(busy_time)
      puts
      assert scheduler.show
    end

  end

end
