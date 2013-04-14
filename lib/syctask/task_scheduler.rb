require_relative 'schedule.rb'
require_relative 'environment.rb'

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
    # Time pattern that matches 24 hour times '12:30'
    TIME_PATTERN = /(2[0-3]|[01]?[0-9]):([0-5]?[0-9])/

    # Work time pattern scans time like '8:00-18:00'
    WORK_TIME_PATTERN = /#{TIME_PATTERN}-#{TIME_PATTERN}/ 

    # Busy time pattern scans times like '9:00-9:30,11:00-11:45'
    BUSY_TIME_PATTERN = 
      /#{TIME_PATTERN}-#{TIME_PATTERN}(?=,)|#{TIME_PATTERN}-#{TIME_PATTERN}$/

    # Scans assignments of tasks to meetings 'A:0,2,4;B:3,4,5'
    ASSIGNMENT_PATTERN = /([a-zA-Z]):(\d+(?:,\d+|\d+;)*)/ 

    # Working directory
    WORK_DIR = Syctask::SYC_DIR #File.expand_path("~/.tasks")

    # Creates a new TaskScheduler. 
    def initialize
      @work_time = []
      @busy_time = []
      @meetings = []
      @tasks = []
    end

    # Set the work time. Raises an exception if begin time is after start time
    # Invokation: set_work_time(["8","0","18","30"])
    def set_work_time(work_time)
      @work_time = process_work_time(work_time)
      unless sequential?(@work_time)
        raise Exception, "Begin time has to be before end time" 
      end
      Syctask::log_work_time("work", @work_time)
    end

    # Set the busy times. Raises an exception if one begin time is after start
    # time
    # Invokation: set_busy_times([["9","30","10","45"],["12","0","13","45"]])
    def set_busy_times(busy_time)
      @busy_time = process_busy_time(busy_time)
      @busy_time.each do |busy|
        unless sequential?(busy)
          raise Exception, "Begin time has to be before end time" 
        end
      end
      Syctask::log_meetings("meeting", @busy_time, @meetings)
    end

    # Sets the titles of the meetings (busy times)
    # Invokation: set_meeting_titles("title1,title2,title3")
    def set_meeting_titles(titles)
      @meetings = titles.split(",") if titles
      Syctask::log_meetings("meeting", @busy_time, @meetings)
    end

    # Sets the tasks for scheduling
    def set_tasks(tasks)
      @tasks = tasks
    end

    # Add scheduled tasks to busy times
    # Invokation: set_task_assignments([["A","1,2,3"],["B","2,5,6,7"]])
    def set_task_assignments(assignments)
      @assignments = assignments.scan(ASSIGNMENT_PATTERN)
      raise "No valid assignment" if @assignments.empty? 
    end

    private

    # Checks the sequence of begin and end time. Returns true if begin is before
    # end time otherwise false
    def sequential?(range)
      return true if range[0].to_i < range[2].to_i
      if range[0].to_i == range[2].to_i
        return true if range[1].to_i < range[3].to_i
      end
      false
    end
    
    # Scans the work time and separates hours and minutes. Raises an Exception
    # if work time is nil or empty 
    def process_work_time(work_time)
      raise Exception, "Work time must not be nil" if work_time.nil?
      time = work_time.scan(WORK_TIME_PATTERN).flatten
      raise Exception, "Work time cannot be empty" if time.empty?
      time
    end
    
    # Scans the busy times and separates hours and minutes. 
    def process_busy_time(busy_time)
      busy_time = "" if busy_time.nil?
      busy_time.scan(BUSY_TIME_PATTERN).each {|busy| busy.compact!}
    end

    public

    # Restores the value of a previous invokation. Posible values are
    # :work_time, :busy_time, :meetings and :assignments
    # Returns true if a value from a previous call is available otherwise false
    def restore(value)
      work_time, busy_time, meetings, assignments = restore_state
      @work_time   = work_time   if value == :work_time
      @busy_time   = busy_time   if value == :busy_time
      @meetings    = meetings    if value == :meetings
      @assignments = assignments if value == :assignments
      return false if value == :work_time   and (@work_time.nil? or @work_time.empty?)
      return false if value == :busy_time   and (@busy_time.nil? or @busy_time.empty?)
      return false if value == :meetings    and (@busy_time.nil? or @meetings.empty?)
      return false if value == :assignments and (@assignments.nil? or @assignments.empty?)
      true
    end
    
    # Prints the meeting list, timeline and task list
    def show
      schedule = Syctask::Schedule.new(@work_time, @busy_time, @meetings, @tasks)
      schedule.assign(@assignments) if @assignments
      schedule.graph.each {|output| puts output}
      save_state @work_time, @busy_time, @meetings, @assignments
      true
    end

    private

    # Saves the work time, busy time, meetings and assignments from the
    # invokation for later retrieval
    def save_state(work_time, busy_time, meetings, assignments)
      state = {work_time: work_time, 
               busy_time: busy_time, 
               meetings: meetings, 
               assignments: assignments}
      FileUtils.mkdir WORK_DIR unless File.exists? WORK_DIR
      state_file = WORK_DIR+'/'+Time.now.strftime("%Y-%m-%d_time_schedule")
      File.open(state_file, 'w') do |file|
        YAML.dump(state, file)
      end
    end

    # Retrieves the state of the last invokation. Returns the work and busy
    # time, meetings and assignments
    def restore_state
      state_file = WORK_DIR+'/'+Time.now.strftime("%Y-%m-%d_time_schedule")
      return [[], [], [], []] unless File.exists? state_file
      state = YAML.load_file(state_file)
      [state[:work_time], 
       state[:busy_time], 
       state[:meetings], 
       state[:assignments]]
    end

  end

end
