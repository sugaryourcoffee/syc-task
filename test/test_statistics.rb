require 'test/unit'
require 'shoulda'

require_relative '../lib/syctask/statistics.rb'

class TestStatistics < Test::Unit::TestCase

  context "Statistics" do

    def setup
      @stats = Syctask::Statistics.new
      @tasks = []
      1.upto(10) do |i|
        @tasks << [i, Time.now.to_s, (Time.now + 60*i).to_s]
      end

    end

    should "calculate average" do
      assert_equal 60 * (10 + 1) / 2, @stats.average(@tasks)
    end

    should "calculate minimum" do
      assert_equal 60, @stats.min(@tasks)
    end

    should "calculate maximum" do
      assert_equal 600, @stats.max(@tasks)
    end

  end

end
