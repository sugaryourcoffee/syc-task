require_relative '../syctime/time_util.rb'
include Syctime

module Syctask
  
  class Statistics

    def average(data)
      sum = 0
      data.each do |d|
        sum += time_for_string(d[2]) - time_for_string(d[1])
      end
      sum / data.size
    end

    def min(data)
      diffs = []
      data.each do |d|
        diffs << time_for_string(d[2]) - time_for_string(d[1])
      end
      diffs.min
    end

    def max(data)
      diffs = []
      data.each do |d|
        diffs << time_for_string(d[2]) - time_for_string(d[1])
      end
      diffs.max
    end

    def stats(data)
      diffs = []
      data.each do |d|
        diffs << time_for_string(d[2]) - time_for_string(d[1])
      end
      [diffs.min, diffs.max, diffs.inject(:+) / diffs.size]
    end
    
  end

end
