require 'rainbow'

module Syctask

  class TaskScheduler
    WORK_TIME_PATTERN = /(\d+)-(\d+)/
    BUSY_TIME_PATTERN = /(\d+)-(\d+)(?=,)|(\d+)-(\d+)$/
    GRAPH_PATTERN = /[\|-]+|\/+/
    BUSY_PATTERN = /\/+/
    FREE_PATTERN = /[\|-]+/

    def initialize(work_time, busy_time)
      @work_time = work_time.scan(WORK_TIME_PATTERN).flatten
      @busy_time = busy_time.scan(BUSY_TIME_PATTERN).each {|busy| busy.compact!}
      puts @work_time
      puts @busy_time
      create_graph(@work_time, @busy_time)
    end

    def print_graph
      @schedule_graph.scan(GRAPH_PATTERN) do |part|
        print sprintf("%s", part).color(:red) unless part.scan(BUSY_PATTERN).empty?
        print sprintf("%s", part).color(:green) unless part.scan(FREE_PATTERN).empty?
      end
      puts
      puts @schedule_units
    end

    def create_graph(work_time, busy_time)
      @schedule_graph = '|---' * (work_time[1].to_i-work_time[0].to_i) + '|'

      @schedule_units = ""
      work_time[0].to_i.upto(work_time[1].to_i) do |time|
        @schedule_units += time.to_s + (time < 9 ? ' ' * 3 : ' ' * 2)
      end

      @busy_time.each do |busy|
        busy_pattern = '/' * 4 * (busy[1].to_i - busy[0].to_i)
        busy_start = 1 + 4 * (busy[0].to_i - work_time[0].to_i)
        busy_end   = busy_start - 1 + busy_pattern.size
        @schedule_graph[busy_start..busy_end] = busy_pattern 
      end
    end


  end

end
