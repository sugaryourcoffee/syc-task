require_relative 'times.rb'
require_relative 'meeting.rb'
require_relative '../sycstring/string_util.rb'
include Sycstring

module Syctask

  # Schedule represents a working day with a start and end time, meeting times
  # and titles and tasks. Tasks can also be associated to meetings as in an
  # agenda.
  # Invokation example
  #     work = ["8","30","18","45"]
  #     busy = [["9","0","10","0"],["11","30","12","15"]]
  #     titles = ["Ruby class room training","Discuss Ruby"]
  #     tasks = [task1,task2,task3,task4,task5,task6]
  #     schedule = Syctask::Schedule.new(work,busy,titles,tasks)
  #     schedule.graph.each {|output| puts output}
  #     
  # This will create following output
  #     Meetings
  #     --------
  #     A - Ruby class room training
  #     B - Discuss Ruby
  #
  #         A         B
  #     xxoo/////xxx|-////oooooxoooo|---|---|---|---|
  #     8   9  10  11  12  13  14  15  16  17  18  19
  #     1 2      3        4    5    
  #                             6
  #
  #     Tasks
  #     -----
  #     0 - 1: task1
  #     1 - 2: task2
  #     2 - 3: task3
  #     3 - 4: task4
  #     4 - 5: task5
  #     5 - 6: task6
  #         
  # Subsequent tasks are are displayed in the graph alternating with x and o.
  # Meetings are indicated with / and the start is marked with A, B and so on.
  # Task IDs are shown below the graph. The graph will be printed colored.
  # Meetings in red, free times in green and tasks in blue. The past time is
  # shown in black.
  class Schedule
    # Color of meetings
    BUSY_COLOR = :red
    # Color of free times
    FREE_COLOR = :green
    # Color of tasks
    WORK_COLOR = :blue
    # If tasks cannot be assigned to the working time this color is used
    UNSCHEDULED_COLOR = :yellow
    # Regex scans tasks and free times in the graph
    GRAPH_PATTERN = /[\|-]+|\/+|[xo]+/
    # Regex scans meetings in the graph
    BUSY_PATTERN = /\/+/
    # Regex scans free times in the graph
    FREE_PATTERN = /[\|-]+/
    # Regex scans tasks in the graph
    WORK_PATTERN = /[xo]+/
 
    # Start time of working day
    attr_reader :starts
    # End time of working day
    attr_reader :ends
    # Meetings assigned to the work time
    attr_accessor :meetings
    # Tasks assigned to the work time
    attr_accessor :tasks

    # Creates a new Schedule and initializes work time, busy times, titles and
    # tasks. Work time is mandatory, busy times, titles and tasks are optional.
    # Values have to be provided as
    # * work time: [start_hour, start_minute, end_hour, end_minute]
    # * busy time: [[start_hour, start_minute, end_hour, end_minute],[...]]
    # * titles:    [title,...]
    # * tasks:     [task,...]
    def initialize(work_time, busy_time=[], titles=[], tasks=[])
      @starts = Syctask::Times.new([work_time[0], work_time[1]])
      @ends = Syctask::Times.new([work_time[2], work_time[3]])
      @meetings = []
      titles ||= []
      busy_time.each.with_index do |busy,index|
        title = titles[index] ? titles[index] : "Meeting #{index}"
        @meetings << Syctask::Meeting.new(busy, title) 
      end
      raise Exception, 
        "Busy times have to be within work time" unless within?(@meetings, 
                                                                @starts, 
                                                                @ends)
      @tasks = tasks
    end

    # Sets the assignments containing tasks that are assigned to meetings.
    # Returns true if succeeds
    def assign(assignments)
      assignments.each do |assignment|
        number = assignment[0].upcase.ord - "A".ord
        return false if number < 0 or number > @meetings.size
        @meetings[number].tasks.clear
        assignment[1].split(',').each do |id|
          index = @tasks.find_index{|task| task.id == id.to_i} 
          @meetings[number].tasks << @tasks[index] if index and @tasks[index]
        end
        @meetings[number].tasks.uniq!
      end
      true
    end

    # Creates a meeting list for printing. Returns the meeting list
    def meeting_list
      list = sprintf("%s", "Meetings\n").color(:red)
      list << sprintf("%s", "--------\n").color(:red)
      meeting_number = "A"
      @meetings.each do |meeting|
        list << sprintf("%s - %s\n", meeting_number, meeting.title).color(:red)
        meeting_number.next!
        meeting.tasks.each do |task|
          task_color = task.done? ? :green : :blue
          list << sprintf("%5s - %s\n", task.id, task.title).color(task_color)
        end
      end      
      list
    end

    # Creates a meeting caption and returns it for printing
    def meeting_caption
      work_time, meeting_times = get_times
      caption = ""
      meeting_number = "A"
      meeting_times.each do |times|
        caption << ' ' * (times[0] - caption.size) + meeting_number 
        meeting_number.next!
      end
      sprintf("%s", caption).color(:red)
    end

    # Creates the time caption for the time line
    def time_caption
      work_time = get_times[0]
      caption = ""
      work_time[0].upto(work_time[1]) do |time|
        caption << time.to_s + (time < 9 ? ' ' * 3 : ' ' * 2)
      end
      sprintf("%s", caption)
    end

    # graph first creates creates the time line. Then the busy times are added.
    # After that the tasks are added to the time line and the task caption and
    # task list is created.
    # graph returns the graph, task caption, task list and meeting list
    # * time line
    # * add meetings to time line
    # * add tasks to time line
    # * create task caption
    # * create task list
    # * create meeting caption
    # * create meeting list
    # * return time line, task caption, task list, meeting caption and meeting
    # list
    def graph
      work_time, meeting_times = get_times
      time_line = "|---" * (work_time[1]-work_time[0]) + "|"
      meeting_times.each do |time|
        time_line[time[0]..time[1]-1] = '/' * (time[1] - time[0])
      end

      task_list, task_caption = assign_tasks_to_graph(time_line)

      [meeting_list, meeting_caption,
       colorize(time_line), time_caption, 
       task_caption, task_list]
    end

    private 

    # Checks if meetings are within work times. Returns true if fullfilled
    # otherwise false
    def within?(meetings, starts, ends)
      meetings.each do |meeting|
        return false if meeting.starts.h < starts.h
        return false if meeting.starts.h == starts.h and 
                        meeting.starts.m < starts.m 
        return false if meeting.ends.h > ends.h
        return false if meeting.ends.h == ends.h and 
                        meeting.ends.m > ends.m
      end
      true
    end

    # Colors the time line free time green, busy time red and tasks blue. The
    # past time is colored black
    def colorize(time_line)
      time_line, future = split_time_line(time_line)
      future.scan(GRAPH_PATTERN) do |part|
        time_line << sprintf("%s", part).color(BUSY_COLOR) unless part.scan(BUSY_PATTERN).empty?
        time_line << sprintf("%s", part).color(FREE_COLOR) unless part.scan(FREE_PATTERN).empty?
        time_line << sprintf("%s", part).color(WORK_COLOR) unless part.scan(WORK_PATTERN).empty?
      end if future
      time_line
    end

    # Splits the time line at the current time. Returning the past part and the
    # future part.
    def split_time_line(time_line)
      time = Time.now
      if time.hour < @starts.h
        past = ""
        future = time_line
      else
        offset = (time.hour - @starts.h) * 4 + time.min.div(15)      
        past = time_line.slice(0,offset)
        future = time_line.slice(offset, time_line.size - offset)
      end
      [past, future]
    end

    # Assigns the tasks to the timeline in alternation x and o subsequent tasks.
    # Returns the task list and the task caption
    def assign_tasks_to_graph(time_line)
      done_tasks = [] #{}
      unscheduled_tasks = []
      signs = ['x','o']
      positions = {}
      current_time = Time.now
      unassigned_tasks.each.with_index do |task, index|
        if task.done? or not task.today?
          done_tasks << task
          next
        else
          round = task.remaining.to_i % 900 == 0 ? 0 : 0.5
          duration = [(task.remaining.to_i/900+round).round, 1].max
          position = [0, position_for_time(current_time)].max
        end
        free_time = scan_free(time_line, 1, position)
        if free_time[0].nil?
          unscheduled_tasks << task
          next
        end
        0.upto(duration-1) do |i| 
          break unless free_time[i]
          time_line[free_time[i]] = signs[index%2]
        end
        positions[free_time[0]] = task.id
      end

      unless done_tasks.empty?
        end_position = position_for_time(current_time)
        total_duration = 0
        done_tasks.each_with_index do |task,index|
          free_time = scan_free(time_line, 1, 0, end_position)
          lead_time = task.duration.to_i - task.remaining.to_i + 0.0
          max_duration = [free_time.size - (done_tasks.size - index - 1), 1].max
          duration = [(lead_time/900).round, 1].max
          total_duration += duration = [duration, max_duration].min
          0.upto(duration-1) do |i|
            break unless free_time[i]
            time_line[free_time[i]] = signs[index%2]
          end
          positions[free_time[0]] = task.id if free_time[0]
        end
      end

      # Create task list
      max_id_size = 1
      @tasks.each {|task| max_id_size = [task.id.to_s.size, max_id_size].max}
      max_ord_size = (@tasks.size - 1).to_s.size

      task_list = sprintf("%s", "Tasks\n").color(:blue)
      task_list << sprintf("%s", "-----\n").color(:blue)
      @tasks.each.with_index do |task, i|
        if task.done? or not task.today?
          color = :green
        elsif unscheduled_tasks.find_index(task)
          color = UNSCHEDULED_COLOR
        else
          color = WORK_COLOR
        end
        offset = max_ord_size + max_id_size + 5
        title = split_lines(task.title, 80-offset)
        title = title.chomp.gsub(/\n/, "\n#{' '*offset}")
        task_list << sprintf("%#{max_ord_size}d: %#{max_id_size}s - %s\n", 
                             i, task.id, title).color(color)
      end

      # Create task caption
      task_caption = ""
      create_caption(positions).each do |caption| 
        task_caption << sprintf("%s\n", caption).color(WORK_COLOR)
      end

      [task_list, task_caption]
 
    end

    # creates the caption of the graph with hours in 1 hour steps and task IDs
    # that indicate where in the schedule a task is scheduled.
    def create_caption(positions)
      counter = 0
      lines = [""]
      positions.each do |position,id|
        next unless position
        line_id = next_line(position,lines,counter)
        legend = ' ' * [0, position - lines[line_id].size].max + id.to_s
        lines[line_id] += legend
        counter += 1
      end
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
      return counter%lines.size if line.size == 0 or line.size < position - 1
      lines.each.with_index do |line, index|
        return index if line.size < position - 1
      end
      lines << ""
      return lines.size - 1
    end

    # Determines the position within the time line for the given time. Each
    # position represents a 15 minute duration. Minutes below 8 will be rounded
    # down otherwise rounded up.
    def position_for_time(time)
      diff = @starts.diff(time)
      ((diff[0] * 60 + diff[1]) / 15.0).round
    end

    # Scans the schedule for free time where a task can be added to. Count
    # specifies the length of the free time and the position where to start
    # scanning within the graph
    def scan_free(graph, count, starts, ends=graph.size)
      pattern = /(?!\/)[\|-]{#{count}}(?<=-|\||\/)/

      positions = []
      index = starts
      while index and index < ends
        index = graph.index(pattern, index)
        if index
          positions << index if index < ends
          index += 1
        end
      end
      positions
    end

    # Returns the tasks that are not assigned to meetings
    def unassigned_tasks
      assigned = []
      @meetings.each do |meeting|
        assigned << meeting.tasks
      end
      assigned.flatten!

      unassigned = []
      unassigned << @tasks
      unassigned.flatten.delete_if {|task| assigned.find_index(task)}
    end

    public

    # Retrieves the work and busy times transformed to the time line scale
    def get_times
      work_time = [@starts.h, @ends.round_up]
      meeting_times = []
      @meetings.each do |meeting|
        meeting_time = Array.new(2)
        meeting_time[0] = hour_offset(@starts.h, meeting.starts.h) + 
          minute_offset(meeting.starts.m)
        meeting_time[1] = hour_offset(@starts.h, meeting.ends.h) + 
          minute_offset(meeting.ends.m)
        meeting_times << meeting_time
      end if @meetings
      
      times = [work_time, meeting_times]
    end

    private

    # Transposes a time hour to a graph hour
    def hour_offset(starts, ends)
      (ends - starts) * 4
    end

    # Transposes a time minute to a graph minute
    def minute_offset(minutes)
      minutes.to_i.div(15)
    end

  end
end
