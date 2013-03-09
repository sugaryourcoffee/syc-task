require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/times.rb'

class TestTimes < Test::Unit::TestCase

  context "Time" do

    should "create Time and read hour and minutes" do
      range = ["8","30"]
      time = Syctask::Times.new(range)
      assert_equal 8, time.h
      assert_equal 30, time.m
      assert_equal 9, time.round_up
    end

    should "create Time and round hours" do
      range = ["8","30"]
      time = Syctask::Times.new(range)
      assert_equal 9, time.round_up
      range = ["8","00"]
      time = Syctask::Times.new(range)
      assert_equal 8, time.round_up
    end

  end
end
