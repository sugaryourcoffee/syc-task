require 'test/unit'
require 'shoulda'

require_relative '../lib/syctime/time_util.rb'
include Syctime

# Test for TimeUtil class
class TestTimeUtil < Test::Unit::TestCase

  context "TimeUtil" do

    should "print time" do
      times = {}
      times[30]   = "30 seconds "
      times[60]   = "1 minute "
      times[90]   = "1 minute 30 seconds "
      times[3600] = "1 hour "
      times[7200] = "2 hours "
      times[         2 * 24 * 60 * 60 + 2 * 60 * 60] = "2 days 2 hours "
      times[         7 * 24 * 60 * 60] = "1 week "
      times[     4 * 7 * 24 * 60 * 60] = "1 month "
      times[12 * 4 * 7 * 24 * 60 * 60] = "1 year "
      times[3 * 12 * 4 * 7 * 24 * 60 * 60] = "3 years "

      times.each do |k,v|
        assert_equal v, Syctime::string_for_seconds(k)
      end
    end

    should "evaluate date between from and to" do
      time = Time.local(2013,"apr",13,10,53,0)
      from = Time.local(2013,"apr",12,11,53,0)
      to   = Time.local(2013,"apr",14,9,53,0)
      assert Syctime::date_between?(time,time,time)
      assert Syctime::date_between?(time,from,to)
      assert Syctime::date_between?("2013-04-13",from,to)
      assert Syctime::date_between?(time,"2013-04-12",to)
      assert Syctime::date_between?(time,from,"2013-04-14")
      time = Time.local(2013,"apr",12,11,55,0)
      assert Syctime::date_between?(time,from,to)
      time = Time.local(2013,"apr",14,12,48,10)
      assert Syctime::date_between?(time,from,to)
      time = Time.local(2012,"apr",13,10,53,0)
      refute Syctime::date_between?(time,from,to)
      time = Time.local(2015,"may",13,10,48,0)
      refute Syctime::date_between?(time,from,to)
      assert_raise(ArgumentError) {Syctime::date_between?("20-23-3",from,to)}
      assert_raise(ArgumentError) {Syctime::date_between?(time,"a-b-2",to)}
      assert_raise(ArgumentError) {Syctime::date_between?(time,from,"1ab")}
    end

    should "evaluate time between from and to" do
      time = Time.now
      from = time
      to   = time
      assert time_between?(time, from, to)
      from = time - 60
      to   = time + 60
      assert time_between?(time, from, to)
      from = time + 60
      to   = time - 60
      refute time_between?(time, from, to)
      from = time + 60
      to   = time + 60
      refute time_between?(time, from, to)
    end

    should "create separated time string" do
      assert_equal "01:00:00", Syctime::separated_time_string(3600, ":")
      assert_equal "01:10:30", Syctime::separated_time_string(4230, ":")
    end

  end

end
