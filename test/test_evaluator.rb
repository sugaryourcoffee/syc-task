require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/evaluator.rb'

# Tests for the Evaluator class
class TestEvaluator < Test::Unit::TestCase

  context "TestEvaluator" do

    # Creates the evaluator object before each shoulda
    def setup
      @evaluator = Syctask::Evaluator.new
    end
    
    should "evaluate number comparisson" do
      assert @evaluator.compare_numbers("1", "<4")
      assert @evaluator.compare_numbers("3", "<4")
      refute @evaluator.compare_numbers("3", ">4")
      assert @evaluator.compare_numbers("3", "=3")
      refute @evaluator.compare_numbers("3", "4")
      refute @evaluator.compare_numbers("", "")
      refute @evaluator.compare_numbers("", "3")
      refute @evaluator.compare_numbers("1", "")
      refute @evaluator.compare_numbers("", "<3")
    end

    should "evaluate date comparisson" do
      assert @evaluator.compare_dates("2013-02-22", "<2013-02-23")
      refute @evaluator.compare_dates("2013-02-22", ">2013-02-23")
      assert @evaluator.compare_dates("2013-02-22", ">2013-02-01")
      refute @evaluator.compare_dates("2013-02-22", "=2013-02-01")
      refute @evaluator.compare_dates("2013-02-22", "2013-02-21")
      refute @evaluator.compare_dates("", "")
      refute @evaluator.compare_dates("2013-02-24", "")
      refute @evaluator.compare_dates("", ">2013-02-21")
      refute @evaluator.compare_dates("", "=2013-02-21")
      assert @evaluator.compare_dates("", "<2013-02-21")
    end

    should "evaluate number array" do
      assert @evaluator.includes?("3", "1,3,8,10")
      assert @evaluator.includes?("3", "3")
      refute @evaluator.includes?("3", "1,4,10,8")
      refute @evaluator.includes?("", "")
      refute @evaluator.includes?("", "1")
      refute @evaluator.includes?("", "2,3")
      refute @evaluator.includes?("3", "")
    end

    should "evaluate string array" do
      assert @evaluator.includes?("speach", "speach,lecture")
      refute @evaluator.includes?("talk", "speach,lecture")
      refute @evaluator.includes?("", "")
      refute @evaluator.includes?("", "speach")
      refute @evaluator.includes?("talk", "")
    end

    should "evaluate a regex" do
      assert @evaluator.matches?("Speach", "[sS]peach")
      assert @evaluator.matches?("reach 2 the sky", "reach \\d the sky")
      refute @evaluator.matches?("Talk for the walk", "Talk \\d the walk")
      assert @evaluator.matches?("", "")
      refute @evaluator.matches?("", "\d empty String")
      assert @evaluator.matches?("Talk", "")
    end

  end

end

