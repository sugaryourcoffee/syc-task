require 'aruba/cucumber'
require 'fileutils'

#ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
# Library directory
#LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

Before do
  # Using "announce" causes massive warnings on 1.9.2
#  @puts = true
#  @original_rubylib = ENV['RUBYLIB']
#  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s

  # Remapping home directory to a fake home directory
  @real_home = ENV['HOME']
  fake_home = File.join('/tmp', 'fake_home')
  FileUtils.rm_rf fake_home, secure: true
  ENV['HOME'] = fake_home

  # Create blank system directory and id file in fake_home
  FileUtils.mkdir_p File.join(ENV['HOME'], ".syc/syctask")
  File.write(File.join(ENV['HOME'], ".syc/syctask/id"), "0")
end

After do
#  ENV['RUBYLIB'] = @original_rubylib
  ENV['HOME'] = @real_home
end
