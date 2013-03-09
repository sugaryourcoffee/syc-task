module Syctask

  class Times

    attr_reader :h
    attr_reader :m

    def initialize(time)
      @h = time[0].to_i
      @m = time[1].to_i
    end

    def round_up
      @m > 0 ? @h+1 : @h
    end

  end

end
