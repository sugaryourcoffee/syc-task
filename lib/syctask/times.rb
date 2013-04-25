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

    # Returns a Time object with the current date and the hour and minute of 
    # this Times object
    def time
      now = Time.now
      Time.local(now.year,now.mon,now.day,@h,@m,0)
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
      signum = diff_minutes == 0 ? 0 : diff_minutes / diff_minutes.abs
      diff_h = diff_minutes.abs / 60
      diff_m = diff_minutes.abs % 60
      if signum < 0
        if diff_h > 0
          [signum * diff_h, diff_m]
        else
          [diff_h, signum * diff_m]
        end
      else
        [diff_h, diff_m]
      end
    end
  end

end
