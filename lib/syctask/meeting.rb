require_relative 'times.rb'

module Syctask

 class Meeting

    attr_accessor :starts
    attr_accessor :ends
    attr_accessor :title
    attr_accessor :tasks

    # Sets the busy time for the schedule. The busy times have to be provided
    # as hh:mm-hh:mm. Optionally a title for the busy time can be provided 
    def initialize(time, title="", tasks=[])
      @starts = Syctask::Times.new(time[0])
      @ends = Syctask::Times.new(time[1])
      @title = title
      @tasks = tasks
    end

  end

end
