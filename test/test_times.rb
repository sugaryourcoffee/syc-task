require 'minitest/autorun' # 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/times.rb'

# Tests for the Times class
class TestTimes < Minitest::Test # Test::Unit::TestCase

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

    should "calculate time difference" do
      range = ["8","30"]
      time = Syctask::Times.new(range)
      diff = time.diff(Time.local(2013,"apr",7,9,0,0))
      assert_equal [0,30], diff
      diff = time.diff(Time.local(2013,"apr",7,9,25,0))
      assert_equal [0,55], diff
      diff = time.diff(Time.local(2013,"apr",7,9,30,0))
      assert_equal [1,0], diff
      diff = time.diff(Time.local(2013,"apr",7,10,35,0))
      assert_equal [2,5], diff 
      diff = time.diff(Time.local(2013,"apr",7,8,30,0))
      assert_equal [0,0], diff
    end

  end
end
