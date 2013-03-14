require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/schedule.rb'

class TestSchedule < Test::Unit::TestCase

  context "Schedule" do

    should "create Schedule with start and end time" do
      time = ["8","30","18","45"]
      schedule = Syctask::Schedule.new(time)
      assert_equal 8, schedule.starts.h
      assert_equal 30, schedule.starts.m
      assert_equal 18, schedule.ends.h
      assert_equal 45, schedule.ends.m

      work, meetings = schedule.get_times
      assert_equal 8, work[0]
      assert_equal 19, work[1]
    end

    should "create schedule with start in future and end in past" do
      expected = [/[\e\[\dm]*(Meetings\n)[\e\[\dm]*/,
                  /\e\[\d+m\e\[\d+m/,
                  /[\e\[\dm]*(\|---\|)[\e\[\dm]*/,
                  /\d+\s+\d+\s+/,
                  /\e\[\d+m\n\e\[\d+m/,
                  /[\e\[\dm]*(Tasks\n)[\e\[\dm]*-----\n[\e\[\dm]/]
      time = ["1","0","2","0"]
      schedule = Syctask::Schedule.new(time) 
      schedule.graph.each_with_index do |output,i| 
        assert_match expected[i], output
      end

      time = ["22","0","23","45"]
      schedule = Syctask::Schedule.new(time)
      schedule.graph.each_with_index do |output,i| 
        assert_match expected[i], output
      end
    end

    should "add meeting and retrieve the start and end time" do
      time = ["8","0","18","0"]
      schedule = Syctask::Schedule.new(time)
      meeting_time = ["9","30","11","0"]
      title = "Test the meeting class"
      meeting = Syctask::Meeting.new(meeting_time, title)
      assert_equal 9, meeting.starts.h
      assert_equal 30, meeting.starts.m
      assert_equal 11, meeting.ends.h
      assert_equal 0, meeting.ends.m
      
      schedule.meetings << meeting
      
      work, meetings = schedule.get_times
      assert_equal 8, work[0]
      assert_equal 18, work[1]
      assert_equal 6, meetings[0][0]
      assert_equal 12, meetings[0][1]      
    end

    should "raise error when busy time before or after work time" do
      time = ["7","9","18","45"]

      busy_times = [["7","9","10","35"],["17","10","18","45"]]
      assert_nothing_raised Exception do
        Syctask::Schedule.new(time, busy_times)
      end

      busy_times = [["6","0","8","50"],["9","0","10","35"]]
      assert_raises Exception do
        Syctask::Schedule.new(time, busy_times)
      end

      busy_times = [["16","33","17","44"],["19","45","20","15"]]
      assert_raises Exception do
        Syctask::Schedule.new(time, busy_times)
      end

      busy_times = [["7","8","11","11"],["12","02","14","34"]]
      assert_raises Exception do
        Syctask::Schedule.new(time, busy_times)
      end

      busy_times = [["15","55","18","45"],["18","46","19","22"]]
      assert_raises Exception do
        Syctask::Schedule.new(time, busy_times)
      end
    end

    should "add tasks and print time line" do
      time = ["8","0","18","30"]
      schedule = Syctask::Schedule.new(time)
      
      meeting_time = ["9","30","11","0"]
      title = "Test the meeting class"
      schedule.meetings << Syctask::Meeting.new(meeting_time, title)

      meeting_time = ["13","30","14","45"]
      title = "Test the task schedule"
      schedule.meetings << Syctask::Meeting.new(meeting_time, title)
 
      puts
      schedule.graph.each {|output| puts output}

      tasks = []
      1..10.times do |i|
        task = Syctask::Task.new({}, "Task number #{i+1}", i+1)
        task.duration = [i+1, 4].min
        task.dir = "test/tasks"
        tasks << task
      end

      schedule.tasks = tasks

      schedule.graph.each {|output| puts output}

      assignments = [["A", "0,2,3"],["B", "0,6,9"]]
      schedule.assign(assignments)

      schedule.graph.each {|output| puts output}

      schedule.tasks[4].done

      schedule.graph.each {|output| puts output}

      assignments = [["A", "2,3"],["B", "0,6,9"]]
      schedule.assign(assignments)

      schedule.graph.each {|output| puts output}
    end
  end

end
