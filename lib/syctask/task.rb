require 'fileutils'

module SycTask

  class Task

    # Holds the options of the task
    attr_accessor :options
    # Title of the class
    attr_reader :title
    # ID of the task
    attr_reader :id
    # Creation date
    attr_reader :creation_date
    # Update date
    attr_reader :update_date
    # Done date
    attr_reader :done_date
    # Directory where the file of the task is located
    attr_reader :dir

    # Creates a new task. If the options contain a note than the current date
    # and time is added.
    def initialize(options={}, title, id)
      @title = title
      @options = options
      @options[:n] = "#{Time.now}\n #{@options[:n]}\n" if @options[:n]
      @id = id
      @creation_date = Time.now
    end
    
    def update(options)
      options.keys.each do |key|
        new_value = options[key]
        
        case key
        when :n
          new_value = "#{Time.now}\n #{new_value}\n #{@options[key]}"
        when :t
          new_value = "#{@options[key]},#{new_value}"
        end

        @options[key] = new_value
      end 
      @update_date = Time.now
    end

    def done(note="")
      if note
        options[:n] = "#{Time.now}\n #{note}\n #{@options[:n]}"
      end
      @done_date = Time.now
    end

    def print_pretty
      
    end

    def print_csv
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
