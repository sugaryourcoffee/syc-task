require 'yaml'

module Syctask

  class TaskService

    def create(dir, options, title)
      create_dir(dir)
      task = Task.new(options, title, create_id(dir))
      save(dir, task)
      task.id
    end

    def read(dir, filter={})
      tasks = []
      Dir.glob("#{dir}/*").each do |file|
        task = YAML.load_file(file)
        tasks << task if task and task.matches?(filter)
      end
      tasks
    end

    def update(dir, id, options)
      task_file = Dir.glob("#{dir}/#{id}.task")[0]
      task = YAML.load_file(task_file) if task_file
      updated = false
      if task
        task.update(options) 
        save(dir, task)
        updated = true
      end
      updated
    end

    private

    # Creates the task directory if it does not exist
    def create_dir(dir)
      FileUtils.mkdir_p dir unless File.exists? dir
    end

    # Creates the task's ID based on the tasks available in the task directory.
    # The task's file name is in the form ID.task. create_id determines
    # the biggest number and adds one to create the task's ID.
    def create_id(dir)
      tasks = Dir.glob("#{dir}/*")
      ids = []
      tasks.each {|task| ids << task.scan(/^\d+(?=\.task)/)[0].to_i}
      ids.compact!
      id = ids.empty? ? 1 : ids[ids.size-1] + 1
#      id = 1
#      unless ids.empty?
#        id = ids[ids.size-1] + 1
#      end
#      id
    end

 
    # Saves the task to the task directory
    def save(dir, task)
      File.open("#{dir}/#{task.id}.task", 'w') {|f| YAML.dump(task, f)}
    end

  end
end


