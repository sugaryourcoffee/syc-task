require 'fileutils'

module SycTask

  class Task

    # Holds the options of the task
    attr_accessor :options
    # Title of the class
    attr_reader :title
    # ID of the task
    attr_reader :id
    # Directory where the file of the task is located
    attr_reader :dir

    # Creates a new task and saves it to the directory specified in the dir
    # attribute. If the directory doesn't exist the directory is created.
    def initialize(dir, options, title)
      create_dir(dir)
      @title = title
      @options = options
      create_task_id
    end
    
    def update(options)
      options.keys.each do |key|
        @options[key] = options[key]
      end 
    end

    private

    # Creates the directory if it does not exist
    def create_dir(dir)
      FileUtils.mkdir_p dir unless File.exists? dir
    end

    # Creates the task's ID based on the tasks available in the task directory.
    # The task's file name is in the form ID.task. create_task_id determines
    # the biggest number and adds one to create the task's ID.
    def create_task_id
      tasks = Dir.glob("#{@dir}/*")
      ids = []
      tasks.each {|task| ids << task.scan(/^\d+(?=\.task)/)[0].to_i }
      if ids.empty?
        @id = 1
      elsif
        @id = ids[ids.size-1] + 1
      end
    end

  end

end
