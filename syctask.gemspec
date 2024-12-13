# frozen_string_literal: true

# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__), 'lib', 'syctask', 'version.rb'])
Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.2'
  s.name = 'syc-task'
  s.version = Syctask::VERSION
  s.author = 'Pierre Sugar'
  s.email = 'pierre@sugaryourcoffee.de'
  s.homepage = 'https://github.com/sugaryourcoffee/syc-task'
  s.license = 'MIT'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Simple task organizer'
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
  # Add your other files here if you make them
  s.files = %w[
    bin/syctask
    lib/syctask/version.rb
    lib/syctask/task.rb
    lib/syctask/task_service.rb
    lib/syctask/task_planner.rb
    lib/syctask/scanner.rb
    lib/syctask/evaluator.rb
    lib/syctask.rb
    lib/syctask/task_scheduler.rb
    lib/syctask/meeting.rb
    lib/syctask/times.rb
    lib/syctask/schedule.rb
    lib/sycutil/console.rb
    lib/sycutil/console_timer.rb
    lib/syctask/environment.rb
    lib/syctask/task_tracker.rb
    lib/syctask/settings.rb
    lib/syctask/statistics.rb
    lib/syctime/time_util.rb
    lib/sycstring/string_util.rb
  ]
  s.require_paths << 'lib'
# s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'syctask.rdoc']
  s.rdoc_options << '--title' << 'syctask' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'syctask' << 'console_timer'
  s.add_development_dependency('aruba')
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('byebug')
  s.add_runtime_dependency('gli', '2.22')
  s.add_runtime_dependency('rainbow', '1.1.4')
  s.add_runtime_dependency('timeleap')
end
