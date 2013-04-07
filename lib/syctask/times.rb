module Syctask

  # Times class represents a time consisting of hour and minutes
  class Times

    # Hour of the Times object
    attr_reader :h
    # Minute of the Times object
    attr_reader :m

    # Creates a new Times object. time has to be provided as an array with the
    # content as ["hour","minute"] e.g. ["10","15"] is 15 past 10
    def initialize(time)
      @h = time[0].to_i
      @m = time[1].to_i
    end

    # Rounds the time to the next hour if minutes is greater than 0
    def round_up
      @m > 0 ? @h+1 : @h
    end

    # Calculates the difference between this time and the provided time. If no
    # time is given the current time is used.
    #     Example:
    #     This time  =  9:35
    #     New time   = 10:20
    #     diff(time) =  0:45
    # Will return [hour,min] in the example [0,45] 
    def diff(time = Time.now)
      diff_minutes = (time.hour - @h) * 60 + (time.min - @m)
      diff_h = diff_minutes / 60 % 60
      diff_m = diff_minutes % 60
      [diff_h, diff_m]
    end
  end

end
