#!/usr/bin/env ruby

require 'yaml'
require 'rainbow'

# ConsoleTimer prints a task and the lead time at the upper right corner of the
# schreen. Invokation example:
# * Create a semaphore like id.track
# * Console time in a new ruby process
#    semaphore = File.expand_path("~/.syc/syctask/#{id}.track"
#    FileUtils.touch semaphore
#    system "ruby lib/sycutil/console_timer.rb 60 10 semaphore"
# This will start the ConsoleTimer with a lead time of 1 minute for task 10.
# To stop the timer the semaphore has to be deleted
#    FileUtils.rm semaphore
class ConsoleTimer

  # Create a new ConsoleTimer with the time to count down, the task's ID and a
  # semaphore. The semaphore is a file named id.track where id is equal to the
  # provided id. The semaphore is checked for existence. If the semaphore is
  # deleted than ConsoleTimer is stopped.
  def initialize(time, id, semaphore)
    @time = time.to_i
    @id = id
    @start = Time.now
    @semaphore = semaphore
  end

  # Starts the timer. The timer is run as long the semaphore is available
  def start
    track = true
    while track
      sleep 1
      output
      track = File.exist? @semaphore
    end
    exit 0
  end

  # Prints the id and the lead time of the currently tracked task. As long as
  # the provided time is greater than 0 the time is printed in green, otherwise
  # red
  def output
    color = :green
    difference = @time - (Time.now - @start).round
    if difference < 0
      difference = difference.abs
      color = :red
    end
    seconds = difference % 60
    minutes = difference / 60 % 60
    hours   = difference / 60 / 60 % 60 
    count_down = sprintf("%d: %02d:%02d:%02d", @id, hours, minutes, seconds)
    size = count_down.size
    count_down = count_down.color(color)
    command = "tput sc;"+
              "tput cup 0 $(($(tput cols) - #{size}));"+
              "echo #{count_down};tput rc"
    system command
  end

end

# Expects to receive parameters duration, id and semaphore
if ARGV.size == 3
  duration = ARGV.shift
  id = ARGV.shift
  semaphore = ARGV.shift
  timer = ConsoleTimer.new(duration, id, semaphore)
  timer.start
else
  exit -1
end


