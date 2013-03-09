require_relative 'times.rb'

module Syctask

  class Schedule

    attr_reader :starts
    attr_reader :ends
    # Meetings assigned to the work time
    attr_accessor :meetings
    # Tasks assigned to the work time
    attr_accessor :tasks

    # Sets the work time for the schedule. The work time has to be provided as
    # [start_hour,start_minute,end_hour,end_minute]
    def initialize(work_time, meetings=[], tasks=[])
      @starts = Syctask::Times.new([work_time[0], work_time[1]])
      @ends = Syctask::Times.new([work_time[2], work_time[3]])
      @meetings = meetings
      @tasks = tasks
    end

    def assign(meeting, tasks)
      meeting.add(tasks)
    end

    def tasks_for(meeting)
      if meeting
        meeting.tasks
      else
        @tasks
      end
    end

    def meeting_list
      list = sprintf("%s", "Meeting\n").color(:red)
      meeting_number = "A"
      @meetings.each do |meeting|
        list += sprintf("%s - %s", meeting_number, meeting.title).color(:red)
        meeting.tasks.each do |task|
          list += sprintf("%s - %s", task.id, task.title).color(:red)
        end
      end      
      list
    end

    def task_list
      list = sprintf("%s", "Tasks\n").color(:blue)
      tasks.each.with_index do |task, index|
        list += sprintf("%d - %s: %s", index, task.id, task.title).color(:blue)
      end
    end

    def meeting_caption
      work_time, meeting_times = get_times
      meeting_number = "A"
      meeting_times.each do |times|
        meeting_caption << ' ' * times[0]-work_time[0] + meeting_number
        meeting_number.next!
      end
    end

    def task_caption

    end

    def time_caption
      work_time = get_times[0]
      work_time[0].upto(work_time[0]) do |time|
        time_caption << time.to_s + (time < 9 ? ' ' * 3 : ' ' * 2)
      end
      sprintf("%s", time_caption)
    end

    def graph
      work_time, meeting_times = get_times
      graph = sprintf("%s", "|---" * (work_time[1]-work_time[0]) + "|").color(:green)  
      meeting_times.each do |time|
        graph[time[0]..time[1]] = sprintf("%s", '/' * (time[1] - time[0]+1)).color(:red)
      end
   end

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
