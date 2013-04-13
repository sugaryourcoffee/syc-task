require 'time'

# Functions for time operations
module Syctime

  # Translates seconds to years, months, weeks, days, hours, minutes and seconds
  # The return value is an array [seconds,...,years]
  def seconds_to_time(seconds)
    seconds = seconds.round
    duration = []
    duration << seconds % 60                         # seconds
    duration << seconds / 60 % 60                    # minutes
    duration << seconds / 60 / 60 % 24               # hours
    duration << seconds / 60 / 60 / 24 % 7           # days
    duration << seconds / 60 / 60 / 24 / 7 % 4       # weeks
    duration << seconds / 60 / 60 / 24 / 7 / 4 % 12  # months
    duration << seconds / 60 / 60 / 24 / 7 / 4 / 12  # years
  end

  # Translates seconds into a time string like 1 year 2 weeks 5 days 10 minutes.
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

  # Creates a time string separating hours, minutes and seconds with the
  # provided separator like 12:50:33
  def separated_time_string(seconds, separator)
    secs  = seconds % 60
    mins  = seconds / 60 % 60
    hours = seconds / 60 / 60 
    time_string = sprintf("%02d#{separator}%02d#{separator}%02d", hours, mins, secs)
  end

  # Translates a time in the ISO 8601 schema to a time object.
  #     2013-04-09 21:45 -200
  def time_for_string(time)
    time = time.scan(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)[0].sub(' ','T')
    Time.xmlschema(time)
  end
  
  # Tests whether the time is between from and to. Returns true then otherwise
  # false. Time, from and to are Time objects as retrieved from Time.now or
  # Time.local(2013,"apr",13,10,50,0). Alternatively time strings can be
  # provided in the form of "2013-04-13".
  def time_between?(time, from, to)
    time = time.strftime("%Y-%m-%d") if time.class == Time
    from = from.strftime("%Y-%m-%d") if from.class == Time
    to   = to.strftime("%Y-%m-%d")   if to.class   == Time
    time_pattern = /\d{4}-\d{2}-\d{2}/
    raise ArgumentError if time.scan(time_pattern).empty?
    raise ArgumentError if from.scan(time_pattern).empty?
    raise ArgumentError if to.scan(time_pattern).empty?
    time >= from && time <= to
  end

end
