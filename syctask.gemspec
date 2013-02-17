# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','syctask','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'syctask'
  s.version = Syctask::VERSION
  s.author = 'Your Name Here'
  s.email = 'your@email.address.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
# Add your other files here if you make them
  s.files = %w(
bin/syctask
lib/syctask/version.rb
lib/syctask.rb
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
end
