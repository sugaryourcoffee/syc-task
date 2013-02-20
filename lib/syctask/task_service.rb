module Syctask

  class TaskService

    def create(dir, options, title)
      create_dir(dir)
      task = Task.new(options, title, create_id(dir))
      save(dir, task)
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
      tasks.each {|task| ids << task.scan(/^\d+(?=\.task)/)[0].to_i }
      id = ids.empty? ? 1 : ids[ids.size-1] + 1
#      id = 1
#      unless ids.empty?
#        id = ids[ids.size-1] + 1
#      end
#      id
    end

 
    # Saves the task to the task directory
    def save(dir, task)

    end

  end
end


