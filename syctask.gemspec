# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','syctask','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'syc-task'
  s.version = Syctask::VERSION
  s.author = 'Pierre Sugar'
  s.email = 'pierre@sugaryourcoffee.de'
  s.homepage = 'http://syc.dyndns.org/drupal/syc-task'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Simple task organizer'
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
# Add your other files here if you make them
  s.files = %w(
bin/syctask
lib/syctask/version.rb
lib/syctask/task.rb
lib/syctask/task_service.rb
lib/syctask/task_planner.rb
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
lib/syctime/time_util.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','syctask.rdoc']
  s.rdoc_options << '--title' << 'syctask' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'syctask'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.5.4')
  s.add_runtime_dependency('rainbow')
end
