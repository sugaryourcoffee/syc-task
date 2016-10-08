require 'rainbow'
require_relative '../syctime/time_util.rb'
require_relative 'settings.rb'

include Syctime

module Syctask
  
  # Creates statistics about the work and meeting times as well about the task
  # processing
  class Statistics

    # Initializes the Statistics object with the general purpose tassk
    def initialize
      settings = Settings::new
      tasks = settings.read_tasks
      @general_purpose_tasks = tasks.nil? ? [] : tasks.keys
    end

    # Creates a statistics report
    def report(file, from="", to=from)
      unless File.exists? file
        return sprintf("Warning: Statistics log file %s", 
                       file.bright).color(:red) +
               sprintf(" is missing!\n%sNo statistics available!\n", 
                       " "*9).color(:red)
      end

      from, to, time_log, count_log = logs(file, from, to)
      working_days = time_log["work"].count.to_s if time_log["work"]
      working_days ||= "0"
      value_size = {key: 0, total: 0, min: 0, max: 0, average: 0}
      report_lines = {}
      report = sprintf("%s to %s", "#{from.strftime("%Y-%m-%d")}".bright,
                                   "#{to.strftime("%Y-%m-%d")}".bright) +
               sprintf(" (%s working days)\n", working_days.bright) +
               sprintf("%24s", "Total".bright) +
               sprintf("%26s", "Min  ".bright) +
               sprintf("%26s", "Max  ".bright) + 
               sprintf("%29s", "Average\n".bright) 
      report << sprintf("%s\n", "Time".bright)
      time_log.each do |key,value|
        total, min, max, average = stats(value)
        total   = Syctime::separated_time_string(total, ":")
        min     = Syctime::separated_time_string(min, ":")
        max     = Syctime::separated_time_string(max, ":")
        average = Syctime::separated_time_string(average, ":")
        set_max_value_sizes(key, total, min, max, average, value_size)
        report_lines[key] = [total, min, max, average]
      end
      
      report << create_report_line_strings(report_lines, value_size)

      report_lines = {}
      value_size = {key: 0, total: 0, min: 0, max: 0, average: 0}
      
      report << sprintf("%s\n", "Count".bright)
      count_log.each do |key,value|
        total, min, max, average = stats_count(value)
        set_max_value_sizes(key, total, min, max, average, value_size)
        report_lines[key] = [total, min, max, average]
      end

      report << create_report_line_strings(report_lines, value_size)

    end

    # Creates report line strings
    def create_report_line_strings(lines, value_size)
      report = ""
      lines.each do |key, value| 
        total   = value[0]
        min     = value[1]
        max     = value[2]
        average = value[3]
        report << report_line(key, total, min, max, average, value_size)
      end
      report
    end

    # Determines the max string size of the values
    def set_max_value_sizes(key, total, min, max, average, value_size)
      value_size[:key]     = [value_size[:key],     key.size].max
      value_size[:total]   = [value_size[:total],   total.size].max
      value_size[:min]     = [value_size[:min],     min.size].max
      value_size[:max]     = [value_size[:max],     max.size].max
      value_size[:average] = [value_size[:average], average.size].max 
    end

    # Creates a report line for the report
    def report_line(key, total, min, max, average, sizes={})
      color = :green if key == 'task' 
      color = :yellow if key == 'unplanned' or @general_purpose_tasks.
                                                 find_index(key)
      key = key[0..8]
      report =  sprintf(" %s#{' '*(10-key.size)}", key).color(color)
      report << sprintf("%#{sizes[:total]}s#{' '*(10-sizes[:total]+8)}", total).
        color(color)
      report << sprintf("%#{sizes[:min]}s#{' '*(10-sizes[:min]+8)}", min).
        color(color)
      report << sprintf("%#{sizes[:max]}s#{' '*(10-sizes[:max]+8)}", max).
        color(color)
      report << sprintf("%#{sizes[:average]}s\n", average).color(color)
    end

    # Calculates the average of a task processing, work or meeting time
    def average(data)
      sum = 0
      data.each do |d|
        sum += time_for_string(d[1]) - time_for_string(d[0])
      end
      sum / data.size
    end

    # Calculates the minimum duration of task processing, work or meeting time
    def min(data)
      diffs = []
      data.each do |d|
        diffs << time_for_string(d[1]) - time_for_string(d[0])
      end
      diffs.min
    end

    # Calculates the maximum duration of task processing, work or meeting time
    def max(data)
      diffs = []
      data.each do |d|
        diffs << time_for_string(d[1]) - time_for_string(d[0])
      end
      diffs.max
    end

    # Calculates total, min, max and average time of task processing, work or
    # meeting time
    def stats(data)
      diffs = []
      data.each do |d|
        diffs << time_for_string(d[1]) - time_for_string(d[0])
      end
      [diffs.inject(:+), diffs.min, diffs.max, diffs.inject(:+) / diffs.size]
    end

    # Calculates the total, min, max and average count of task processing, 
    # creation, update, done, delete
    def stats_count(data)
      count = []
      data.each do |key,value|
        count << value.to_i 
      end
      [count.inject(:+), count.min, count.max, count.inject(:+) / count.size]
    end
    
    # Retrieves the log entries from the log file
    def logs(file, from="", to=from)
      times = []
      time_data  = {}
      time_types = %w{work meeting task}
      time_types << @general_purpose_tasks
      time_types.flatten!
      count_data = {}
      count_types = %w{meeting task create done update delete}
      count_types << @general_purpose_tasks
      count_types.flatten!
      IO.readlines(file).each do |line|
        values = line.split(";")
        time = time_for_string(values[4])
        times << time
        next if values[0] == "start"
        unless from == ""
          next unless Syctime::date_between?(time, from, to)
        end
        values[0] = values[3] if @general_purpose_tasks.find_index(values[3])
        values[0] = "task" if values[0] == "stop"
        if count_types.find_index(values[0])
          time = time.strftime("%Y-%m-%d")
          count_data[values[0]] = {} unless count_data[values[0]]
          count_data[values[0]][time] = 0 unless count_data[values[0]][time]
          count_data[values[0]][time] += 1
          if @general_purpose_tasks.find_index(values[0])
            count_data['unplanned'] = {} unless count_data['unplanned']
            count_data['unplanned'][time] = 0 unless \
              count_data['unplanned'][time]
            count_data['unplanned'][time] += 1
          end 
        end
        if time_types.find_index(values[0])
          time_data[values[0]] = [] unless time_data[values[0]]
          time_data[values[0]] << [values[4],values[5]]
          if @general_purpose_tasks.find_index(values[0])
            time_data['unplanned'] = [] unless time_data['unplanned']
            time_data['unplanned'] << [values[4],values[5]]
          end
        end
      end
      from = times.min if from == ""
      to   = times.max if to   == ""
      [from, to, time_data, count_data]
    end

  end

end
