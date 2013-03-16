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

  end

end
