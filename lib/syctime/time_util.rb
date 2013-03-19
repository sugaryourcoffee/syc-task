module Syctime

  def seconds_to_time(seconds)
    seconds = seconds.round
    duration = []
    duration << seconds % 60                             # seconds
    duration << seconds / 60 % 60                        # minutes
    duration << seconds / 60 / 60 % 60                   # hours
    duration << seconds / 60 / 60 / 60 % 24              # days
    duration << seconds / 60 / 60 / 60 / 24 % 7          # weeks
    duration << seconds / 60 / 60 / 60 / 24 / 7 % 4      # months
    duration << seconds / 60 / 60 / 60 / 24 / 7 / 4 % 12 # years
  end

  def string_for_seconds(seconds)
    time = seconds_to_time(seconds)
    time_name = ['year','month','week','day','hour','minute','second']
    time_string = ""
    time.reverse.each_with_index do |part,index|
      time_string << part.to_s + ' ' + time_name[index] + ' ' if part == 1
      time_string << part.to_s + ' ' + time_name[index] + 's ' if part > 1
    end
    time_string
  end

end
