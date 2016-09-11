require_relative 'task'

# Syctask provides functions for managing tasks in a task list
module Syctask

  # A Scanner scans text or files for tasks. The task is identified by an
  # annotation
  #
  # Example
  # -------
  # @tasks;
  # title;description;prio;follow_up
  # Title 1;Description 1;;2016-09-10
  # Title 2;Description 2;1;2016-09-20
  #
  # @tasks; is indicating that tasks are following separated by ';'. The next
  # line describes to which fields the values belong to. The next lines are the
  # actual field values.
  class Scanner

    # The scan type @tasks scan all tasks, @task scan the next task
    attr_reader :scan
    # Indicates whether task has been scanned since last @task(s) annotation
    attr_reader :scanned
    # The separator that separates task values
    attr_reader :separator
    # The task fields
    attr_reader :task_fields
    # The task counter holding tasks scanned
    attr_reader :task_count
    # The scanned tasks
    attr_reader :tasks

    # Creates a new scanner
    def initialize
      @tasks = {}
    end

    # Scans the content in regard to tasks. 'content' may be a file or a string.
    # It checks if 'content' is a file and if it exists scans the file otherwise
    # it asumes the content to be text and scans accordingly.
    def scan(content)
      if File.exists? content
        scan_file(content)
      else
        scan_text(content)
      end 
      @tasks
    end

    # Scans a file for tasks
    def scan_file(file)
      File.read_lines(file) do |line|
        scan_line(line.chomp)
      end
    end

    # Scans a text for tasks
    def scan_text(text)
      text.each_line do |line|
        scan_line(line.chomp)
      end
    end

    # Scans a string (line) for tasks
    def scan_line(line)
      if line.strip =~ /^@tasks./
        @scan, @separator = line.scan(/(@tasks)(.)/).flatten
        @scanned = false
      elsif line.strip =~ /^@task./
        @scan, @separator = line.scan(/(@task)(.)/).flatten
        @scanned = false
      else
        if not @scanned
          load_task_fields(line) || scan_task_line(line)
        elsif multiple_scan?
          scan_task_line(line)
        end
      end
    end

    # Checks if the 'line' contains task fields. If it contains task fields it
    # sets the @task_fields and returns true, otherwise returns false
    def load_task_fields(line)
      task_fields = line.split(@separator)
      if (Syctask::Task::FIELDS & task_fields).empty?
        false
      else
        @task_fields = task_fields.map { |f| f.strip.downcase.to_sym }
        true
      end
    end

    # Scans the 'line' for task values
    def scan_task_line(line)
      task_values = line.split(@separator)
      if @task_fields && (@task_fields.size == task_values.size)
        #@tasks << { title_of(task_values) => options_of(task_values) }
        @tasks[title_of(task_values)] = options_of(task_values)
        @scanned = true
      end
    end

    # Retrieves the 'title' value from the task_values which is an array
    def title_of(task_values)
      task_values[@task_fields.index(:title)].strip
    end


    # Retrieves the task values except for the 'title' value and returns a
    # hash of the task values
    def options_of(task_values)
      task_values = task_values - [task_values[@task_fields.index(:title)]]
      task_fields = @task_fields - [:title]
      options = {}
      task_fields.each_with_index do |field, index|
        options[field] = task_values[index]
      end
      options
    end

    # Checks whether multiple tasks should be scanned which is indicated by
    # '@scan == '@tasks'.
    def multiple_scan?
      @scan == '@tasks'
    end
  end

end

