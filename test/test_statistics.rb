require 'minitest/autorun' # 'test/unit'
require 'shoulda'

require_relative '../lib/syctask/statistics.rb'

# Test the Statistics class
class TestStatistics < Minitest::Test # Test::Unit::TestCase

  context "Statistics" do

    # Create tasks and entries.
    # * Tasks
    #     start|stop;id;dir;title;start;
    # * Entries
    #     type;id;dir;title;start;stop
    #     type = start|stop|work|meeting|done|update|delete
    setup do
      backup_system_files("TestStatistics")
      @stats = Syctask::Statistics.new
      @tasks = []
      1.upto(10) do |i|
        @tasks << [Time.now.to_s, (Time.now + 60*i).to_s]
      end
      @entries = "" 
      types = %w{work meeting start stop done update delete}
      1.upto(5) do |i|
        start = Time.local(2013,"apr","#{i+11}",8,15,0)
        stop  = Time.local(2013,"apr","#{i+11}",18,30,0)
        @entries << "#{types[0]};-1;;work;#{start};#{stop}\n"
        @entries << "#{types[1]};-2;;meeting;#{start+i*60};#{start+i*120}\n"
        0.upto(9) do |i|
          @entries << "#{types[i%5+2]};#{i};test/tasks;"+
                      "task #{i};"+
                      "#{start+i*60};#{start+(i+1)*60}\n"  
        end
      end
      File.open(Syctask::TASKS_LOG, 'w') {|f| f.puts @entries}
    end

    # Restore the system files
    teardown do
      restore_system_files("TestStatistics")
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

    should "calculate stats" do
      total, min, max, average = @stats.stats(@tasks)
      assert_equal 3300, total
      assert_equal 60, min
      assert_equal 600, max
      assert_equal 60 * (10 + 1) / 2, average
    end

    should "retrieve data from today" do
      time = Time.local(2013,"apr",12,15,10,0)
      from, to, time_log, count_log = @stats.logs(Syctask::TASKS_LOG, time)
      assert_equal time.strftime("%Y-%m-%d"), from.strftime("%Y-%m-%d")
      assert_equal time.strftime("%Y-%m-%d"), to.strftime("%Y-%m-%d")
      assert_equal 3, time_log.size
      assert_equal 5, count_log.size
    end

    should "retrieve report" do
      from = Time.local(2013,"apr",12,15,10,0)
      to   = Time.local(2013,"apr",12,15,10,0)
      report = @stats.report(Syctask::TASKS_LOG, from, to)
      refute_empty report
      report = @stats.report(Syctask::TASKS_LOG)
      refute_empty report
    end

  end

end
