require 'rainbow'

module Syctask

  # The TaskScheduler creates a graphical representation of a working schedule
  # with busy times visualized. A typical invokation would be
  #     work_time = "8:00-18:00"
  #     busy_time = "9:00-9:30,13:00-14:30"
  #     scheduler = Syctask::TaskScheduler.new(work_time, busy_time)
  #     scheduler.print_graph
  # The output would be
  #     |---///-|---|---|---///////-|---|---|---|
  #     8   9  10  11  12  13  14  15  16  17  18
  # To add tasks to the schedule tasks have to provided (see Task). A task has
  # a duration which indicates the time it is planned to process a task. The
  # duration is an Integer 1,2,.. where 1 is 15 minutes and 2 is 30 minutes and
  # so on. Assuming we have 5 tasks with a duration of 2, 5, 3, 2 and 3 15
  # minute chunks. Then the invokation of 
  #     scheduler.schedule_tasks(tasks)
  # would output the schedule
  #     |xx-///ooooo|xxx|oo-///////xxx--|---|---|
  #     8   9  10  11  12  13  14  15  16  17  18
  # The tasks are added to the schedule dependent on the time chunks and the
  # available free time gaps. 
  class TaskScheduler
    # Time matcher that matches a 24 hour time
    TIME_MATCHER = /(2[0-3]|[01]?[0-9]):([0-5]?[0-9])/
    # Time pattern that matches 24 hour times
    TIME_PATTERN = /(2[0-3]|[01]?[0-9]):([0-5]?[0-9])/
    # Work time pattern scans time like "8:00-18:00"
    WORK_TIME_PATTERN = /#{TIME_PATTERN}-#{TIME_PATTERN}/ 
    WORK_TIME_MATCHER = /^#{TIME_MATCHER}-#{TIME_MATCHER}/
    # Busy time pattern scans times like "9:00-9:30,11:00-11:45"
    BUSY_TIME_PATTERN = /#{TIME_PATTERN}-#{TIME_PATTERN}(?=,)|#{TIME_PATTERN}-#{TIME_PATTERN}$/
    BUSY_TIME_MATCHER = /^#{TIME_MATCHER}-#{TIME_MATCHER}(?:,#{TIME_MATCHER}-#{TIME_MATCHER})*/
    GRAPH_PATTERN = /[\|-]+|\/+|[xo]+/
    BUSY_PATTERN = /\/+/
    FREE_PATTERN = /[\|-]+/
    WORK_PATTERN = /[xo]+/
    BUSY_COLOR = :red
    FREE_COLOR = :green
    WORK_COLOR = :blue
    UNSCHEDULED_COLOR = :yellow

    # Creates a TaskScheduler with the provided work_time and busy_time. The
    # work_time has to be in the form like "8:00-18:00", the busy_time has
    # comma separated busy times like "9:00-10:30,11:00-11:30". If the begin
    # and end time is not sequential an Exception is raised.
    def initialize(work_time, busy_time)
      @work_time = work_time.scan(WORK_TIME_PATTERN).flatten
      raise Exception, "Work time cannot be empty" if work_time.nil? or work_time.empty?
      busy_time = "" if busy_time.nil?
      @busy_time = busy_time.scan(BUSY_TIME_PATTERN).each {|busy| busy.compact!}
      if range_is_sequential?
        normalize_time
        create_graph(@work_time, @busy_time)
      else
        raise Exception, "Begin time has to be before end time"
      end
    end

    #Assigns available free time slots to the tasks and prints the visual
    #representation of the schedule.
    def schedule_tasks(tasks)
      unscheduled_tasks = []
      max_id_size = 1
      signs = ['x','o']
      positions = {}
      position = 0
      tasks.each.with_index do |task, index|
        duration = task.duration.to_i
        free_time = scan_free(duration, position)
        #TODO if no free time available for the complete duration than
        #distribute in all free spaces. Return all not assigned time chunks
        next unless free_time 
        position = free_time[0]
        max_id_size = [max_id_size, duration.to_s.size].max
        if position.nil?
          unscheduled_tasks << task
          next
        end
        @schedule_graph[position..(position + duration-1)] = 
          signs[index%2] * duration
        positions[position] = task.id
      end
      tasks.each do |task|
        if unscheduled_tasks.find_index(task)
          color = UNSCHEDULED_COLOR
        else
          color = WORK_COLOR
        end
        puts sprintf("%#{max_id_size}d - %s", task.id, task.title).
                color(color)
      end

      create_caption(positions).each do |caption| 
        puts sprintf("%s", caption.color(WORK_COLOR))
      end
      print_graph
    end

    private

    # Checks whether the begin and end time of work_time and busy_time is 
    # sequential. If the begin is before the end time of all time ranges true
    # is returned otherwise false
    def range_is_sequential?
      return false unless check_sequence(@work_time)
      @busy_time.each do |busy|
        return false unless check_sequence(busy)
      end
      true
    end

    # Checks the sequence of begin and end time. Returns true if begin is before
    # end time otherwise false
    def check_sequence(range)
      return true if range[0].to_i < range[2].to_i
      if range[0].to_i == range[2].to_i
        return true if range[1].to_i < range[3].to_i
      end
      false
    end
 
    # Transposes the time ranges to the graph size of the schedule
    def normalize_time
      @graph_ranges = []
      @graph_ranges[0] = @work_time[0].to_i
      @graph_ranges[1] = @work_time[3].to_i > 0 ? @work_time[2].succ.to_i : @work_time[2].to_i
      
      @busy_ranges = []
      @busy_time.each do |busy|
        busy_range = Array.new(2)
        busy_range[0] = (busy[0].to_i - @graph_ranges[0]) * 4 + minute_offset(busy[1])
        busy_range[1] = (busy[2].to_i - @graph_ranges[0]) * 4 + minute_offset(busy[3])
        @busy_ranges << busy_range
      end
    end

    # Transposes a time hour to a graph hour
    def hour_offset(starts, ends)
      (ends - starts) * 4
    end

    # Transposes a time minute to a graph minute
    def minute_offset(minutes)
      minutes.to_i.div(15)
    end

    public

    # Prints the schedule graph
    def print_graph
      @schedule_graph.scan(GRAPH_PATTERN) do |part|
        print sprintf("%s", part).color(BUSY_COLOR) unless part.scan(BUSY_PATTERN).empty?
        print sprintf("%s", part).color(FREE_COLOR) unless part.scan(FREE_PATTERN).empty?
        print sprintf("%s", part).color(WORK_COLOR) unless part.scan(WORK_PATTERN).empty?
      end
      puts
      puts @schedule_units
      true
    end

    private

    # Creates a graph based on work_time and busy_time
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

    # creates the caption of the graph with hours in 1 hour steps and task IDs
    # that indicate where in the schedule a task is scheduled.
    def create_caption(positions)
      counter = 0
      lines = [""]
      positions.each do |position,id|
        line_id = next_line(position,lines,counter)
        legend = ' ' * [0, position - lines[line_id].size].max + id.to_s
        lines[line_id] += legend
        counter += 1
      end
      #print_graph
      #lines.each {|line| puts line}
      lines
    end

    # Creates a new line if the the task ID in the caption would override the
    # task ID of a previous task. The effect is shown below
    #     |xx-|//o|x--|
    #     8   9  10  10
    #      10    101 
    #       11     2
    # position is the position (time) within the schedule
    # lines is the available ID lines (above we have 2 ID lines)
    # counter is the currently displayed line. IDs are displayed alternating in
    # each line, when we have 2 lines IDs will be printed in line 1,2,1,2...
    def next_line(position, lines, counter)
      line = lines[counter%lines.size]
      #puts "line.size = #{line.size} position = #{position}"
      return counter%lines.size if line.size == 0 or line.size < position - 1
      lines.each.with_index do |line, index|
        #puts "index = #{index.class}"
        return index if line.size < position - 1
      end
      lines << ""
      return lines.size - 1
    end

    # Scans the schedule for free time where a task can be added to. Count
    # specifies the length of the free time and the position where to start
    # scanning within the schedule
    def scan_free(count, position)
      pattern = /(?!\/)[\|-]{#{count}}(?<=-|\||\/)/

      positions = []
      index = position
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
