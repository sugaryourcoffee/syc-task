require 'rainbow'

module Syctask

  class TaskScheduler
    TIME_PATTERN = /(2[0-3]|[01]?[0-9]):([0-5]?[0-9])/
    WORK_TIME_PATTERN = /#{TIME_PATTERN}-#{TIME_PATTERN}/ 
    BUSY_TIME_PATTERN = /#{TIME_PATTERN}-#{TIME_PATTERN}(?=,)|#{TIME_PATTERN}-#{TIME_PATTERN}$/
    GRAPH_PATTERN = /[\|-]+|\/+/
    BUSY_PATTERN = /\/+/
    FREE_PATTERN = /[\|-]+/

    def initialize(work_time, busy_time)
      @work_time = work_time.scan(WORK_TIME_PATTERN).flatten
      @busy_time = busy_time.scan(BUSY_TIME_PATTERN).each {|busy| busy.compact!}
      if range_is_sequential?
        normalize_time
        create_graph(@work_time, @busy_time)
      end
    end

    def range_is_sequential?
      return false unless check_range(@work_time)
      @busy_time.each do |busy|
        return false unless check_range(busy)
      end
      true
    end

    def check_range(range)
      return false unless range[0].to_i < range[2].to_i
      if range[0].to_i == range[2].to_i
        return false unless range[1].to_i < range[3].to_i
      end
      true
    end
 
    def normalize_time
      @graph_ranges = []
      @graph_ranges[0] = @work_time[0].to_i
      @graph_ranges[1] = @work_time[3].to_i > 0 ? @work_time[2].succ.to_i : @work_time[2]
      
      @busy_ranges = []
      @busy_time.each do |busy|
        busy_range = Array.new(2)
        busy_range[0] = (busy[0].to_i - @graph_ranges[0]) * 4 + minute_offset(busy[1])
        busy_range[1] = (busy[2].to_i - @graph_ranges[0]) * 4 + minute_offset(busy[3])
        @busy_ranges << busy_range
      end
    end

    def hour_offset(starts, ends)
      (ends - starts) * 4
    end

    def minute_offset(minutes)
      minutes.to_i.div(15)
    end

    def print_graph
      return -1 unless @schedule_graph
      @schedule_graph.scan(GRAPH_PATTERN) do |part|
        print sprintf("%s", part).color(:red) unless part.scan(BUSY_PATTERN).empty?
        print sprintf("%s", part).color(:green) unless part.scan(FREE_PATTERN).empty?
      end
      puts
      puts @schedule_units
    end

    def create_graph(work_time, busy_time)
      @schedule_graph = '|---' * (@graph_ranges[1]-@graph_ranges[0]) + '|'

      @schedule_units = ""
      @graph_ranges[0].to_i.upto(@graph_ranges[1]) do |time|
        @schedule_units += time.to_s + (time < 9 ? ' ' * 3 : ' ' * 2)
      end

      @busy_ranges.each do |busy|
        @schedule_graph[busy[0]..busy[1]] = '/' * (busy[1] - busy[0]+1)
      end

    end

    def scan_free(count)
      pattern = /(?!\/)[\|-]{#{count}}(?<=-|\||\/)/
      puts pattern
      puts @schedule_graph

      positions = []
      index = 0
      while index and index < @schedule_graph.size
        index = @schedule_graph.index(pattern, index)
        if index
          positions << index
          index += 1
        end
      end
      positions
    end

  end

end
