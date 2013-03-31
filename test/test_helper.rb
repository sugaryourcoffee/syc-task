require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_scheduler.rb'
include Syctask

# Overrides Test::Unit::TestCase to add some helper methods for each test
class Test::Unit::TestCase 

  # Backs up system files before manipulating them in the test
  def backup_system_files
    system_files = Dir.glob("#{Syctask::SYC_DIR}/*")
    system_files.each do |f|
      FileUtils.mv f, f + ".original"
      FileUtils.touch f
    end
  end

  # Restores the file systems after the test
  def restore_system_files
    Dir.glob("#{Syctask::SYC_DIR}/*").each do |f|
      if f.end_with? ".original" 
        FileUtils.mv f, f.sub(".original", "") 
      else
        FileUtils.rm f 
      end
    end
  end

end
