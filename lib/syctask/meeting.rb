require_relative 'times.rb'

module Syctask

  # Meeting represents a meeting containing the begin and end time, a title and
  # an agenda consisting of tasks
  class Meeting

    # The start time of the meeting
    attr_accessor :starts
    # The end time of the meeting
    attr_accessor :ends
    # The title of the meeting
    attr_accessor :title
    # The agenda or tasks of the meeting
    attr_accessor :tasks

    # Sets the busy time for the schedule. The busy times have to be provided
    # as hh:mm-hh:mm. Optionally a title for the busy time can be provided 
    def initialize(time, title="", tasks=[])
      @starts = Syctask::Times.new(time[0..1])
      @ends = Syctask::Times.new(time[2..3])
      @title = title
      @tasks = tasks
    end

  end

end
