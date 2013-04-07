require 'yaml'
require_relative 'environment.rb'

module Syctask

  class Settings

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

    def read_tasks
      if File.exists? Syctask::DEFAULT_TASKS
        YAML.load_file(Syctask::DEFAULT_TASKS) 
      end
    end

  end

end
