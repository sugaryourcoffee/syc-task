require 'fileutils'
require 'rainbow'
require_relative 'evaluator'
require_relative 'environment.rb'
require_relative 'task_tracker.rb'

# Syctask provides functions for managing tasks in a task list
module Syctask

  # A Task is the basic element of the task list and holds all information
  # about a task.
  class Task

    include Comparable

    # The fields that can be set for a task
    FIELDS = ["title", "description", 
              "follow_up", "due_date", "prio", 
              "note", "tags"]
    # Holds the options of the task. 
    # Options are
    # * description - additional information about the task
    # * follow_up   - follow-up date of the task
    # * due_date    - due date of the task
    # * prio        - priority of the task
    # * note        - information about the progress or state of the task
    # * tags        - can be used to search for tasks that belong to a certain 
    #                 category
    attr_accessor :options
    # Title of the class
    attr_reader :title
    # ID of the task
    attr_reader :id
    # Duration specifies the planned time for processing the task
    attr_reader :duration
    # Remaining time is the duration subtracted by the lead time since last plan
    attr_reader :remaining
    # Lead time is the time this task has been processed
    attr_reader :lead_time
    # Creation date
    attr_reader :creation_date
    # Update date
    attr_reader :update_date
    # Done date
    attr_reader :done_date
    # Directory where the file of the task is located
    attr_accessor :dir

    # Creates a new task. If the options contain a note than the current date
    # and time is added.
    def initialize(options={}, title, id)
      @creation_date = Time.now.strftime("%Y-%m-%d - %H:%M:%S")
      @title = title
      @options = options
      @options[:note] = 
                  "#{@creation_date}\n#{@options[:note]}\n" if @options[:note]
      if @options[:follow_up] or @options[:due_date]
        @duration = 2 * 15 * 60
        @remaining = 2 * 15 * 60
      else
        @duration = 0
        @remaining = 0
      end
      @id = id
    end
    
    # Compares this task with another task regarding id and dir. If both are 
    # equal true is returned otherwise false
    def ==(other)
      @id == other.id and @dir == other.dir
    end

    # Compares this Task to the other task and compares them regarding the ID 
    # and the dir. If ID is equal then dir is compared
    def <=>(other)
      id_compare = @id.to_i <=> other.id.to_i
      if id_compare == 0
        @dir <=> other.dir
      else
        id_compare
      end
    end

    # Updates the task with new values. Except for note and tags which are
    # supplemented with the new values and not overridden.
    def update(options)
      @update_date = Time.now.strftime("%Y-%m-%d - %H:%M:%S")
      if options[:duration]
        set_duration(options.delete(:duration).to_i * 15 * 60)
      elsif options[:follow_up] or options[:due_date]
        set_duration(2 * 15 * 60) if @duration.nil?
      end
      options.keys.each do |key|
        new_value = options[key]
        
        case key
        when :note
          new_value = "#{@update_date}\n#{new_value}\n#{@options[key]}"
        when :tags
          unless @options[key].nil?
            if @options[key].include? new_value
              new_value = @options[key]
            else
              new_value = "#{@options[key]},#{new_value}"
            end
          end
        end

        @options[key] = new_value
      end 
    end

    # Checks whether this task has been updated. Returns true if updated
    # otherwise false
    def update?
      !@updated_date.nil?
    end

    # Sets the duration that this task is planned for processing. Assigns to
    # remaining the duration time
    def set_duration(duration)
      @duration = duration
      @remaining = duration
    end

    # Updates the lead time. Adds the lead time to @lead_time and calculates
    # @remaining
    def update_lead_time(lead_time)
      if @lead_time
        @lead_time += lead_time
      else
        @lead_time = lead_time
      end
      if @remaining
        @remaining -= lead_time
      else
        @remaining = @duration.to_i - lead_time
      end
    end

    # Marks the task as done. When done than the done date is set. Optionally a
    # note can be provided.
    def done(note="")
      @done_date = Time.now.strftime("%Y-%m-%d - %H:%M:%S")
      if note
        options[:note] = "#{@done_date}\n#{note}\n#{@options[:note]}"
      end
      Syctask::log_task("done", self)
    end

    # Checks if this task is done. Returns true if done otherwise false
    def done?
      !@done_date.nil?
    end

    # Checks if task is scheduled for today. Returns true if follow up or due
    # date is today otherwise false.
    def today?
      evaluator = Evaluator.new
      today = Time.now.strftime("%Y-%m-%d")
      evaluator.compare_dates(@options[:follow_up], today) or \
       evaluator.compare_dates(@options[:due_date], today) 
    end

    # Checks whether the task is currently tracked. Returns true if so otherwise
    # false
    def tracked?
      tracker = Syctask::TaskTracker.new
      task = tracker.tracked_task
      task.nil? ? false : task == self
    end

    # Compares the provided elements in the filter with the correspondent
    # elements in the task. When all comparissons match than true is returned.
    # If one comparisson does not match false is returned. If filter is empty
    # than true is returned. The values can be compared regarding <, =, > or 
    # whether the task's value is part of a list of provided values. It is also
    # possible to provide a regex as a filter. Following comparissons are
    # available
    # Value                           Compare
    # :title                          regex
    # :description                    regex
    # :id                             contains, <|=|> no operator same as =
    # :prio                           contains, <|=|> no operator same as =
    # :tags                           contains, regex
    # :follow_up                      <|=|>
    # :due                            <|=|>
    def matches?(filter = {})
      return true if filter.empty?
      evaluator = Evaluator.new
      filter.each do |key, value|
        matches = false
        case key
        when :title, :t
          matches = evaluator.matches?(@title, value)
        when :description
          matches = evaluator.matches?(@options[:description], value)
        when :id, :i, "id", "i"
          matches = (evaluator.includes?(@id, value) or 
                     evaluator.compare_numbers(@id, value))
        when :prio, :p
          matches = (evaluator.includes?(@options[:prio], value) or
                     evaluator.compare(@options[:prio], value))
        when :tags
          matches = evaluator.matches?(@options[:tags], value)
        when :follow_up, :f, :d, :due_date
          matches = evaluator.compare_dates(@options[key], value)
        end
        return false unless matches
      end
      true
    end

    # Prints the task in a formatted way eather all values when long is true
    # or only id, title, prio, follow-up and due date.
    def print_pretty(long=false)
      pretty_string(long)
    end

    # Prints the task as a CSV
    def print_csv
      STDOUT.puts(csv_string)
    end

    private

    # Creates the directory if it does not exist
    def create_dir(dir)
      fileutils.mkdir_p dir unless file.exists? dir
    end

    # creates the task's id based on the tasks available in the task directory.
    # the task's file name is in the form id.task. create_task_id determines
    # the biggest number and adds one to create the task's id.
    def create_task_id
      tasks = dir.glob("#{@dir}/*")
      ids = []
      tasks.each {|task| ids << task.scan(/^\d+(?=\.task)/)[0].to_i }
      if ids.empty?
        @id = 1
      elsif
        @id = ids[ids.size-1] + 1
      end
    end

    # Prints the task formatted. Values that are nil are not printed. A type all
    # will print all available values. Otherwise only ID, title, description,
    # prio, follow-up and due date are printed.
    def pretty_string(long)
      color = :default
      color = :green if self.done?
      
      title = split_lines(@title, 70)
      title = title.chomp.gsub(/\n/, "\n#{' '*7}")
      title << ">" if !options[:note].nil?
      puts sprintf("%04d - %s", @id, title.bright).color(color)

      if @options[:description]
        description = split_lines(@options[:description].chomp, 70)
        description = description.chomp.gsub(/\n/, "\n#{' '*7}")
        puts sprintf("%6s %s", " ", description.chomp).color(color) 
      end
      puts sprintf("%6s Prio: %s", " ", @options[:prio]).
        color(color) if @options[:prio]
      puts sprintf("%6s Follow-up: %s", " ", @options[:follow_up]).
        color(color) if @options[:follow_up]
      puts sprintf("%6s Due: %s", " ", @options[:due_date]).
        color(color) if @options[:due_date]
      if long
        if @options[:note]
          note = split_lines(@options[:note].chomp, 70)
          note = note.chomp.
            gsub(/\n(?!\d{4}-\d{2}-\d{2} - \d{2}:\d{2}:\d{2})/, "\n#{' '*9}") 
          note = note.
            gsub(/\n(?=\d{4}-\d{2}-\d{2} - \d{2}:\d{2}:\d{2})/, "\n#{' '*7}")
          puts sprintf("%6s %s", " ", note.chomp).color(color)
        end
        puts sprintf("%6s Tags: %s", " ", @options[:tags]).
          color(color) if @options[:tags]
        puts sprintf("%6s Created: %s", " ", @creation_date).color(color)
        puts sprintf("%6s Updated: %s", " ", @update_date).
          color(color) if @update_date
        puts sprintf("%6s Closed: %s", " ", @done_date).
          color(color) if @done_date
      end
    end

    # Prints all values as a csv separated with ";". This string can be read by
    # another application. The values are
    # id;title;description;prio;follow-up;due;note;tags;created;
    # updated|UNCHANGED;DONE|OPEN
    def csv_string
      string =  "#{@id};#{@title};"
      string += "#{@options[:description]};#{@options[:prio]};"
      string += "#{@options[:follow_up]};#{@options[:due_date]};"
      string += "#{@options[:note] ? @options[:note].gsub(/\n/, '\\n') : ""};"
      string += "#{@options[:tags]};"
      string += "#{@creation_date};"
      string += "#{@udpate_date ? "UPDATED" : "UNCHANGED"};"
      string += "#{@done_date ? "DONE" : "OPEN"}"
      string
    end

    # Splits a string to size (chars) less or equal to length
    def split_lines(string, length)
      lines = string.squeeze(" ").split("\n")
      i = 0
      new_lines = []
      new_lines[i] = ""
      lines.each do |line|
        line.squeeze(" ").split.each do |w|
          if new_lines[i].length + w.length < length
            new_lines[i] += "#{w} "
          else
            i += 1
            new_lines[i] = "#{w} "
          end
        end
        i += 1
        new_lines[i] = ""
      end
      text = ""
      new_lines.each {|l| text << "#{l}\n"}
      text.chomp
    end

  end

end
