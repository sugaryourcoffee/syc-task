require 'test/unit'
require 'shoulda'

require_relative '../lib/syctime/time_util.rb'
include Syctime

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

  end

end
