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
      @options[:n] = "#{@creation_date}\n#{@options[:n]}\n" if @options[:n]
      @id = id
    end
    
    # Updates the task with new values. Except for note and tags which are
    # supplemented with the new values and not overridden.
    def update(options)
      @update_date = Time.now.strftime("%Y-%m-%d - %H:%M:%S")
      options.keys.each do |key|
        new_value = options[key]
        
        case key
        when :n
          new_value = "#{@update_date}\n#{new_value}\n#{@options[key]}"
        when :t
          new_value = "#{@options[key]},#{new_value}"
        end

        @options[key] = new_value
      end 
    end

    # Marks the task as done. When done than the done date is set. Optionally a
    # note can be provided.
    def done(note="")
      @done_date = Time.now.strftime("%Y-%m-%d - %H:%M:%S")
      if note
        options[:n] = "#{@done_date}\n#{note}\n#{@options[:n]}"
      end
    end

    def matches?(filter = {})
      return false if filter.empty?
      evaluator = Evaluator.new
      puts self.id
      puts filter.inspect
      filter.each do |key, value|
        puts "key = #{key} = #{value}"
        matches = false
        case key
        when :title, :t
          matches = evaluator.matches?(@title, value)#@title == value
        when :description
          matches = evaluator.matches?(@options[:description], value)
        when :id, :i, "id", "i"
          puts "in id"
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
        puts "matches?>#{matches}<"
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
      printf("\n%04d - %s\n", @id, @title)
      printf("%6s %s\n", " ", @options[:description]) if @options[:description]
      printf("%6s Prio:      %s\n", " ", @options[:p]) if @options[:p]
      printf("%6s Follow-up: %s\n", " ", @options[:f]) if @options[:f]
      printf("%6s Due:       %s", " ", @options[:d]) if @options[:d]
      if long
        if @options[:n]
          note = @options[:n].chomp.
            gsub(/\n(?!\d{4}-\d{2}-\d{2} - \d{2}:\d{2}:\d{2})/, "\n#{' '*9}") 
          note = note.
            gsub(/\n(?=\d{4}-\d{2}-\d{2} - \d{2}:\d{2}:\d{2})/, "\n#{' '*7}")
          printf("\n%6s %s", " ", note.chomp)
        end
        printf("\n%6s Tags:    %s", " ", @options[:t]) if @options[:t]
        printf("\n%6s Created: %s", " ", @creation_date)
        printf("\n%6s Updated: %s", " ", @update_date) if @update_date
        printf("\n%6s Closed:  %s", " ", @done_date) if @done_date
      end
    end

    # Prints all values as a csv separated with ";". This string can be read by
    # another application. The values are
    # id;title;description;prio;follow-up;due;note;tags;created;
    # updated|UNCHANGED;DONE|OPEN
    def csv_string
      string = "\n#{@id};#{@title};"
      string +" #{@options[:description]};#{@options[:p]};"
      string += "#{@options[:f]};#{@options[:d]};"
      string += "#{@options[:n].gsub(/\n/, '\\n')};"
      string += "#{@options[:t]};"
      string += "#{@creation_date};"
      string += "#{@udpate_date ? @update_date : "UNCHANGED"};"
      string += "#{@done_date ? "DONE" : "OPEN"}\n"
      string
    end

  end

end
