require 'yaml'

module Syctask

  class TaskService

    def create(dir, options, title)
      create_dir(dir)
      task = Task.new(options, title, create_id(dir))
      save(dir, task)
      task.id
    end

    # Reads the task with given ID id located in given directory dir. If task
    # does not exist nil is returned otherwise the task is returned
    def read(dir, id)
      task = nil
      Dir.glob("#{dir}/*").each do |file|
        task = YAML.load_file(file) if File.file? file
        return task if task and task.id == id.to_i
      end
      nil
    end

    # Finds all tasks that match the given filter. The filter can be provided
    # for :id, :title, :description, :follow_up, :due, :tags and :prio.
    # :id can be eather a selection of IDs ID1,ID2,ID3 or a comparison <|=|>ID.
    # :title and :description can be a REGEX as /look for \d+ examples/
    # :follow-up and :due can be <|=|>DATE
    # :tags can be eather a selection TAG1,TAG2,TAG3 or a REGEX /[Ll]ecture/
    # :prio can be <|=|>PRIO 
    def find(dir, filter={}, all=true)
      tasks = []
      Dir.glob("#{dir}/*").sort.each do |file|
        File.file?(file) ? task = YAML.load_file(file) : next
        next if task and not all and task.done?
        next if not task 
        tasks << task if task.matches?(filter)
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

    # Saves the task to the task directory
    def save(dir, task)
      File.open("#{dir}/#{task.id}.task", 'w') {|f| YAML.dump(task, f)}
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
      tasks.each do |task| 
        id = File.basename(task).scan(/^\d+(?=\.task)/)[0]
        ids << id.to_i if id
      end
      ids.empty? ? 1 : ids.sort[ids.size-1] + 1
   end

 
  end
end


