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

    should "add meeting and retrieve the start and end time" do
      time = ["8","0","18","0"]
      schedule = Syctask::Schedule.new(time)
      meeting_time = [["9","30"],["11","0"]]
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

  end

end
