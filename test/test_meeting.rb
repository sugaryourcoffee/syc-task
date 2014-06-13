require 'minitest/autorun' # 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/meeting.rb'

# Tests for the Meeting class
class TestMeeting < Minitest::Test #Test::Unit::TestCase

  context "Meeting" do

    should "create meeting" do
      time = ["9","30","11","0"]
      title = "Test the meeting class"
      meeting = Syctask::Meeting.new(time, title)
      assert_equal 9, meeting.starts.h
      assert_equal 30, meeting.starts.m
      assert_equal 11, meeting.ends.h
      assert_equal 0, meeting.ends.m
      assert_equal "Test the meeting class", meeting.title
    end
  end

end
