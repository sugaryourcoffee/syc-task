require_relative 'times.rb'
require_relative 'meeting.rb'

module Syctask

  class Schedule
    BUSY_COLOR = :red
    FREE_COLOR = :green
    WORK_COLOR = :blue
    UNSCHEDULED_COLOR = :yellow
    GRAPH_PATTERN = /[\|-]+|\/+|[xo]+/
    BUSY_PATTERN = /\/+/
    FREE_PATTERN = /[\|-]+/
    WORK_PATTERN = /[xo]+/
 
    attr_reader :starts
    attr_reader :ends
    # Meetings assigned to the work time
    attr_accessor :meetings
    # Tasks assigned to the work time
    attr_accessor :tasks

    # Sets the work time for the schedule. The work time has to be provided as
    # [start_hour,start_minute,end_hour,end_minute]
    def initialize(work_time, busy_time=[], titles=[], tasks=[])
      @starts = Syctask::Times.new([work_time[0], work_time[1]])
      @ends = Syctask::Times.new([work_time[2], work_time[3]])
      @meetings = []
      titles ||= []
      puts "in Schedule"
      puts busy_time.inspect
      busy_time.each.with_index do |busy,index|
        title = titles[index] ? titles[index] : "Meeting #{index}"
        @meetings << Syctask::Meeting.new(busy, title) 
      end
      @tasks = tasks
    end

    def meeting(titles)
      @meetings.each.with_index do |meeting|
        meeting.title = titles[index] if titles[index]
      end
    end

    def assign(meeting, tasks)
      number = meeting.upcase.ord - "A".ord
      return false if number < 0 or number > @meetings.size
      tasks.each do |index|
        @meetings[number].tasks << @tasks[index] if @tasks[index]
      end
      @meetings[number].tasks.uniq!
      true
    end

    def assign_all(assignments)
      puts assignments.inspect
      assignments.each do |assignment|
        number = assignment[0].upcase.ord - "A".ord
        return false if number < 0 or number > @meetings.size
        assignment[1].split(',').each do |index|
          @meetings[number].tasks << @tasks[index.to_i] if @tasks[index.to_i]
        end
        @meetings[number].tasks.uniq!
      end
      true
    end

    def unassign(meeting, tasks)
      number = meeting.upcase.ord - "A".ord
      return false if number < 0 or number > @meetings.size
      tasks.each do |index|
        @meetings[number].tasks.delete_at(index)
      end
      true
    end

    def tasks_for(meeting)
      if meeting
        meeting.tasks
      else
        @tasks
      end
    end

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
      puts work_time.inspect
      puts meeting_times.inspect
      time_line = "|---" * (work_time[1]-work_time[0]) + "|"
      meeting_times.each do |time|
        time_line[time[0]..time[1]] = '/' * (time[1] - time[0]+1)
      end

      task_list, task_caption = assign_tasks_to_graph(time_line)

      [meeting_list, meeting_caption,
       colorize(time_line), time_caption, 
       task_caption, task_list]
    end

    private 

    def colorize(time_line)
      time_line, future = split_time_line(time_line)
      future.scan(GRAPH_PATTERN) do |part|
        time_line << sprintf("%s", part).color(BUSY_COLOR) unless part.scan(BUSY_PATTERN).empty?
        time_line << sprintf("%s", part).color(FREE_COLOR) unless part.scan(FREE_PATTERN).empty?
        time_line << sprintf("%s", part).color(WORK_COLOR) unless part.scan(WORK_PATTERN).empty?
      end if future
      time_line
    end

    def split_time_line(time_line)
      time = Time.now
      offset = (time.hour - @starts.h) * 4 + time.min.div(15)      
      past = time_line.slice(0,offset)
      future = time_line.slice(offset, time_line.size - offset)
      [past, future]
    end

    def assign_tasks_to_graph(time_line)
      unscheduled_tasks = []
      signs = ['x','o']
      positions = {}
      position = 0
      unassigned_tasks.each.with_index do |task, index|
        duration = task.duration.to_i
        free_time = scan_free(time_line, duration, position)
        position = free_time[0]
        if position.nil?
          unscheduled_tasks << task
          next
        end
        time_line[position..(position + duration-1)] = 
          signs[index%2] * duration
        positions[position] = task.id
      end

      max_id_size = 1
      @tasks.each {|task| max_id_size = [task.id.to_s.size, max_id_size].max}
      max_ord_size = (@tasks.size - 1).to_s.size

      task_list = sprintf("%s", "Tasks\n").color(:blue)
      task_list << sprintf("%s", "-----\n").color(:blue)
      @tasks.each.with_index do |task, i|
        if task.done?
          color = :green
        elsif unscheduled_tasks.find_index(task)
          color = UNSCHEDULED_COLOR
        else
          color = WORK_COLOR
        end
        task_list << sprintf("%#{max_ord_size}d: %#{max_id_size}s - %s\n", i, task.id, task.title).
                       color(color)
      end

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

    # Scans the schedule for free time where a task can be added to. Count
    # specifies the length of the free time and the position where to start
    # scanning within the graph
    def scan_free(graph, count, position)
      pattern = /(?!\/)[\|-]{#{count}}(?<=-|\||\/)/

      positions = []
      index = position
      while index and index < graph.size
        index = graph.index(pattern, index)
        if index
          positions << index
          index += 1
        end
      end
      positions
    end

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

    def get_times
      work_time = [@starts.h, @ends.round_up]
      meeting_times = []
      @meetings.each do |meeting|
        meeting_time = Array.new(2)
        puts meeting.title
        puts "#{meeting.starts.h}:#{meeting.starts.m}"
        puts "#{meeting.ends.h}:#{meeting.ends.m}"
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
