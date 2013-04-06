require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_scheduler.rb'
include Syctask

# Overrides Test::Unit::TestCase to add some helper methods for each test
class Test::Unit::TestCase 

  # Calculates the seconds for the provided time units. One unit is 900
  # seconds or 15 minutes. This time is used in Syctask#Task e.g. for the
  # duration. Returns the time in seconds
  def units_to_time(units)
    units * 15 * 60
  end

  # Backs up system files before manipulating them in the test
  def backup_system_files(caller)
    #log_system_files("Backup: start/#{caller}") 
    system_files = Dir.glob("#{Syctask::SYC_DIR}/*")
    system_files.each do |f|
      FileUtils.mv f, f + ".original"
      FileUtils.touch f
    end
    #log_system_files("Backup: end")
  end

  # Restores the file systems after the test
  def restore_system_files(caller)
    #log_system_files("Restore: start/#{caller}")
    originals = []
    Dir.glob("#{Syctask::SYC_DIR}/*").each do |f|
      if f.end_with? ".original" 
        originals << f
      else
        FileUtils.rm f 
      end
    end
    originals.each {|o| FileUtils.mv o, o.sub(".original", "")}
    #log_system_files("Restore: end")
  end

  def log_system_files(message)
    File.open('syctask_test.log', 'a') do |f|
      f.puts "#{Time.now} - #{message} #{self}"
      f.puts `ls #{Syctask::SYC_DIR}`
    end
  end

end
