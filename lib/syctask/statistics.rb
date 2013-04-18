require 'rainbow'
require_relative '../syctime/time_util.rb'
include Syctime

module Syctask
  
  # Creates statistics about the work and meeting times as well about the task
  # processing
  class Statistics

    # Creates a statistics report
    def report(file, from="", to=from)

      from, to, time_log, count_log = logs(file, from, to)
      working_days = time_log["work"].count.to_s if time_log["work"]
      working_days ||= "0"
      report = sprintf("%s to %s", "#{from.strftime("%Y-%m-%d")}".bright,
                                   "#{to.strftime("%Y-%m-%d")}".bright) +
               sprintf(" (%s working days)\n", working_days.bright) +
               sprintf("%23s", "Total".bright) +
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
        report << report_line(key, total, min, max, average)
      end

      report << sprintf("%s\n", "Count".bright)
      count_log.each do |key,value|
        total, min, max, average = stats_count(value)
        report << report_line(key, total, min, max, average)
      end

      report

    end

    # Creates a report line for the report
    def report_line(key, total, min, max, average)
      report =  sprintf(" %s#{' '*(9-key.size)}", key)
      report << sprintf("%8s#{' '*10}", total)
      report << sprintf("%8s#{' '*10}", min)
      report << sprintf("%8s#{' '*10}", max)
      report << sprintf("%8s\n", average)
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
      count_data = {}
      count_types = %w{meeting task create done update delete}
      IO.readlines(file).each do |line|
        values = line.split(";")
        time = time_for_string(values[4])
        times << time
        next if values[0] == "start"
        unless from == ""
          next unless Syctime::time_between?(time, from, to)
        end
        values[0] = "task" if values[0] == "stop"
        if count_types.find_index(values[0])
          time = time.strftime("%Y-%m-%d")
          count_data[values[0]] = {} unless count_data[values[0]]
          count_data[values[0]][time] = 0 unless count_data[values[0]][time]
          count_data[values[0]][time] += 1
        end
        if time_types.find_index(values[0])
          time_data[values[0]] = [] unless time_data[values[0]]
          time_data[values[0]] << [values[4],values[5]]
        end
      end
      from = times.min if from == ""
      to   = times.max if to   == ""
      [from, to, time_data, count_data]
    end

  end

end
