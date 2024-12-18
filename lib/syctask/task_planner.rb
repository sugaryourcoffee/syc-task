require 'fileutils'
require 'rainbow'
require_relative '../sycutil/console.rb'
require_relative '../syctime/time_util.rb'
require_relative 'task_service.rb'
require_relative 'environment.rb'

module Syctask
  # String that is prompted during planning
  PROMPT_STRING = '(a)dd, (c)omplete, (s)kip, (q)uit: '
  # String that is prompted during inspect
  INSPECT_STRING = '(e)dit, (d)one, de(l)ete, (p)lan, da(t)e, (c)omplete, '+
                   '(s)kip, (b)ack, (q)uit: '
  # String that is prompted during prioritization
  PRIORITIZE_STRING = 'Task 1 has (h)igher or (l)ower priority, or (q)uit: '

  # A TaskPlanner prompts the user to select tasks for today. These tasks can
  # be prioritized to determine the most to the least important tasks.
  class TaskPlanner
    # The task where the planned tasks are saved to
    WORK_DIR = Syctask::SYC_DIR #File.expand_path("~/.tasks")

    # Creates a new TaskPlanner
    def initialize
      @console = Sycutil::Console.new
      @service = TaskService.new
      make_todo_today_file(Time.now.strftime("%Y-%m-%d"))
    end

    # List each task and prompt the user whether to add the task to the planned
    # tasks. The user doesn't specify a duration for the task operation the
    # duration will be set to 30 minutes which equals two time chunks. The
    # count of planned tasks is returned
    def plan_tasks(tasks, date=Time.now.strftime("%Y-%m-%d"))
      already_planned_tasks = self.get_tasks(date)
      tasks = tasks.delete_if { |t| already_planned_tasks.include?(t) }
      count = 0
      re_display = false
      planned = []
      tasks.each do |task|
        unless re_display
          task.print_pretty
        else
          task.print_pretty(true)
          re_display = false
        end
        choice = @console.prompt PROMPT_STRING
        case choice
        when 'a'
          duration = 0
          until duration > 0
            print "Duration (1 = 15 minutes, RETURN defaults to 30 minutes): "
            answer = gets.chomp
            duration = answer.empty? ? 2 : answer.to_i
          end
          task.set_duration(units_to_time(duration))
          task.options[:follow_up] = date
          @service.save(task.dir, task)
          planned << task
          count += 1
        when 'c'
          re_display = true
          redo
        when 's'
          #do nothing
        when 'q'
          break
        end
      end
      save_tasks(planned)
      count
    end

    # Inspect allows to edit, delete and mark tasks as done
    def inspect_tasks(tasks, date=Time.now.strftime("%Y-%m-%d"))
      already_planned_tasks = self.get_tasks(date)
      tasks = tasks.delete_if { |t| already_planned_tasks.include?(t) }
      count = 0
      re_display = false
      planned = []
      index = 0
      while index < tasks.length
        task = tasks[index]
        unless re_display
          task.print_pretty
        else
          task.print_pretty(true)
          re_display = false
        end
        choice = @console.prompt INSPECT_STRING
        case choice
        when 'e'
          task_file = "#{task.dir}/#{task.id}.task"
          system "vi #{task_file}" if File.exist? task_file
          tasks[index] = @service.read(task.dir, task.id)
          redo
        when 'd'
          puts "Enter a note or hit <RETURN>"
          note = gets.chomp
          task.done(note)
          @service.save(task.dir, task)
          tasks.delete(task)
          STDOUT.puts sprintf("--> Marked task %d as done", 
                              task.id).color(:green)
        when 'l'
          print "Confirm delete task (Y/n)? "
          answer = gets.chomp
          del = @service.delete(task.dir, {id: task.id.to_s}) if answer == "Y"
          if del.nil? or del == 0
            puts sprintf("--> Task not deleted").color(:green)
          elsif del > 0
            tasks.delete(task)
            puts sprintf("--> Deleted %d task%s", 
                         del, del == 1 ? "" : "s").color(:green)
          end
        when 'p'
          duration = 0
          until duration > 0
            print "Duration (1 = 15 minutes, RETURN defaults to 30 minutes): "
            answer = gets.chomp
            duration = answer.empty? ? 2 : answer.to_i
          end
          task.set_duration(units_to_time(duration))
          task.options[:follow_up] = date
          @service.save(task.dir, task)
          planned << task
          tasks.delete(task)
          count += 1
        when 't'
          begin
            print "Date (yyyy-mm-dd or 'time distance', e.g. tom, i2d, nfr): "
            specific_date = gets.chomp
          end until valid_date?(specific_date)

          duration = 0
          until duration > 0
            print "Duration (1 = 15 minutes, RETURN defaults to 30 minutes): "
            answer = gets.chomp
            duration = answer.empty? ? 2 : answer.to_i
          end

          task.set_duration(units_to_time(duration))
          task.options[:follow_up] = extract_time(specific_date)
          @service.save(task.dir, task)
          if task.options[:follow_up] == date
            planned << task
            tasks.delete(task)
            count += 1
          else
            index += 1
          end
        when 'c'
          re_display = true
          redo
        when 'b'
          index -= 1 if index > 0
        when 's'
          index += 1
        when 'q'
          break
        end
      end
      save_tasks(planned)
      count
    end

    # Order tasks in the provided IDs sequence at the specified date. If not all
    # IDs are provided than rest of tasks is appended to the end of the plan. If
    # a position (last, first and a number) is provided the ordered tasks are 
    # inserted at the specified position. Returns the count of ordered tasks,
    # the count of the rest of the tasks and the position where the ordered 
    # tasks have been inserted.
    def order_tasks(date, ids, pos=0)
      tasks = get_tasks(date)
      pos = "0" if pos.class == String and pos.downcase == 'first'
      pos = tasks.size.to_s if pos.class == String and pos.downcase == 'last'
      ordered = []
      ids.each do |id|
        index = tasks.find_index {|t| t.id == id.to_i}
        ordered << tasks.delete_at(index) if index
      end
      pos = [pos.to_i.abs,tasks.size].min
      tasks.insert(pos, ordered)
      save_tasks(tasks.flatten!, true)
      [ordered.size, tasks.size, pos]
    end

    # Prioritize tasks by pair wise comparisson. Each task is compared to the
    # other tasks and the user can select the task with the higher priority. So
    # the task with highest priority will bubble on top followed by the task
    # with second highest priority and so on.
    def prioritize_tasks(date=Time.now.strftime("%Y-%m-%d"), filter={})
      tasks = get_tasks(date, filter)
      return false if tasks.nil?
      quit = false
      0.upto(tasks.size-1) do |i|
        (i+1).upto(tasks.size-1) do |j|
          puts " 1: #{tasks[i].title}"
          puts " 2: #{tasks[j].title}"
          choice = @console.prompt PRIORITIZE_STRING
          case choice
          when 'q'
            quit = true
            break
          when 'l'
            tasks[i],tasks[j] = tasks[j],tasks[i]
          end
        end
        break if quit
      end
      save_tasks(tasks, true)
      true
    end

    # Add the task to the planned tasks of the specified date. The task is only
    # added if not already present
    def add_task(task, date=Time.now.strftime("%Y-%m-%d"))
      add_tasks([task], date)
    end

    # Add the tasks to the planned tasks. A task is only added if not already
    # present
    def add_tasks(tasks, date=Time.now.strftime("%Y-%m-%d"))
      planned = get_tasks(date)
      tasks.each do |task|
        planned << task unless planned.find_index {|t| t == task}
      end
      save_tasks(planned, true)
    end

    # Moves the specified tasks to the specified date. Sets the remaining timer
    # to at least 15 minutes and sets the duration to the remaining timer's 
    # values. Returns the count of moved files
    def move_tasks(filter={}, from_date=Time.now.strftime("%Y-%m-%d"), to_date)
      return 0 if from_date == to_date
      moved = get_tasks(from_date, filter)
      moved.each do |task| 
        task.options[:follow_up] = to_date
        task.set_duration([task.remaining, 900].max)
        @service.save(task.dir, task)
      end
      add_tasks(moved, to_date)
      remove_tasks(from_date, filter)
    end

    # Remove planned tasks from the task plan based on the provided filter
    # (filter options see Task#matches?). Returns the count of removed tasks
    def remove_tasks(date=Time.now.strftime("%Y-%m-%d"), filter={})
      planned = []
      tasks = self.get_tasks(date)
      tasks.each do |task|
        planned << task unless task.matches?(filter)
      end
      (tasks - planned).each do |task|
        if task.options[:follow_up] == date
          task.options[:follow_up] = nil
        end
        if task.options[:due_date] == date
          task.options[:due_date] = nil
        end
        @service.save(task.dir, task)
      end
      save_tasks(planned, true)
      tasks.size - planned.size
    end

    # Get planned tasks of the specified date. Retrieve only tasks that match
    # the specified filter (filter options see Task#matches?)
    def get_tasks(date=Time.now.strftime("%Y-%m-%d"), filter={})
      make_todo_today_file(date)
      tasks = []
      File.open(@todo_today_file, 'r') do |file|
        file.each do |line|
          dir, id = line.chomp.split(",")
          task = @service.read(dir, id)
          tasks << task if not task.nil? and task.matches?(filter)
        end
      end if File.exist? @todo_today_file
      tasks
    end

   private

    # Calculates the time for time units. One time unit equals to 900 seconds or
    # 15 minutes. The return value is in seconds
    def units_to_time(units)
      units * 15 * 60
    end

    # Creates a file where the planned tasks are saved to
    def make_todo_today_file(date)
      file_name = Time.now.strftime("#{date}_planned_tasks")
      @todo_today_file = WORK_DIR+"/"+file_name
    end

    # Save the tasks to the todo_today_file. If override is true the file is
    # overriden otherwise the tasks are appended
    def save_tasks(tasks, override=false)
      mode = override ? 'w' : 'a'
      FileUtils.mkdir_p WORK_DIR unless File.exist? WORK_DIR
      File.open(@todo_today_file, mode) do |file|
        tasks.each do |task|
          file.puts("#{task.dir},#{task.id}")
        end 
      end
    end

  end

end
