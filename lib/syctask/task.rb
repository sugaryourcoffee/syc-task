require 'fileutils'
require_relative 'evaluator'

module Syctask

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
      @creation_date = Time.now.strftime("%Y-%m-%d - %H:%M:%S")
      @title = title
      @options = options
      @options[:note] = 
                  "#{@creation_date}\n#{@options[:note]}\n" if @options[:note]
      @id = id
    end
    
    # Updates the task with new values. Except for note and tags which are
    # supplemented with the new values and not overridden.
    def update(options)
      @update_date = Time.now.strftime("%Y-%m-%d - %H:%M:%S")
      options.keys.each do |key|
        new_value = options[key]
        
        case key
        when :note
          new_value = "#{@update_date}\n#{new_value}\n#{@options[key]}"
        when :tags
          if @options[key].include? new_value
            new_value = @options[key]
          else
            new_value = "#{@options[key]},#{new_value}"
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

    # Marks the task as done. When done than the done date is set. Optionally a
    # note can be provided.
    def done(note="")
      @done_date = Time.now.strftime("%Y-%m-%d - %H:%M:%S")
      if note
        options[:note] = "#{@done_date}\n#{note}\n#{@options[:note]}"
      end
    end

    # Checks if this task is done. Returns true if done otherwise false
    def done?
      !@done_date.nil?
    end

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
      STDOUT.puts(pretty_string(long))
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
      printf("\n%04d - %s", @id, @title)
      printf("\n%6s %s", " ", @options[:description]) if @options[:description]
      printf("\n%6s Prio: %s", " ", @options[:prio]) if @options[:prio]
      printf("\n%6s Follow-up: %s", " ", @options[:follow_up]) if @options[:follow_up]
      printf("\n%6s Due: %s", " ", @options[:due]) if @options[:due]
      if long
        if @options[:note]
          note = split_lines(@options[:note].chomp, 70)
          note = note.chomp.
            gsub(/\n(?!\d{4}-\d{2}-\d{2} - \d{2}:\d{2}:\d{2})/, "\n#{' '*9}") 
          note = note.
            gsub(/\n(?=\d{4}-\d{2}-\d{2} - \d{2}:\d{2}:\d{2})/, "\n#{' '*7}")
          printf("\n%6s %s", " ", note.chomp)
        end
        printf("\n%6s Tags: %s", " ", @options[:tags]) if @options[:tags]
        printf("\n%6s Created: %s", " ", @creation_date)
        printf("\n%6s Updated: %s", " ", @update_date) if @update_date
        printf("\n%6s Closed: %s", " ", @done_date) if @done_date
      end
    end

    # Prints all values as a csv separated with ";". This string can be read by
    # another application. The values are
    # id;title;description;prio;follow-up;due;note;tags;created;
    # updated|UNCHANGED;DONE|OPEN
    def csv_string
      string = "\n#{@id};#{@title};"
      string +" #{@options[:description]};#{@options[:prio]};"
      string += "#{@options[:follow_up]};#{@options[:due]};"
      string += "#{@options[:note].gsub(/\n/, '\\n')};"
      string += "#{@options[:tags]};"
      string += "#{@creation_date};"
      string += "#{@udpate_date ? "UPDATED" : "UNCHANGED"};"
      string += "#{@done_date ? "DONE" : "OPEN"}\n"
      string
    end

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
