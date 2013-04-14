require 'yaml'
require_relative 'environment.rb'

module Syctask

  # Creates settings for syctask that are saved to files and retrieved when
  # syctask is started
  class Settings

    # Creates general purpose tasks that can be tracked with syctask start. The
    # general purpose files are saved to a file default_tasks in the syctask
    # system directory
    def tasks(tasks)
      service = Syctask::TaskService.new
      if File.exists? Syctask::DEFAULT_TASKS
        general = YAML.load_file(Syctask::DEFAULT_TASKS)
      else
        general = {}
      end
      tasks.split(',').each do |task|
        index = general.keys.find_index(task.upcase)
        general[task.upcase] = service.create(Syctask::SYC_DIR,
                                              {},
                                              task.upcase) unless index
      end
      File.open(Syctask::DEFAULT_TASKS, 'w') {|f| YAML.dump(general, f)}
    end

    # Retrieves the general purpose files from the default_tasks file in the
    # syctask system directory
    def read_tasks
      if File.exists? Syctask::DEFAULT_TASKS
        YAML.load_file(Syctask::DEFAULT_TASKS) 
      else
        {}
      end
    end

  end

end
