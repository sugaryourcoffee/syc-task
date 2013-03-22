require 'fileutils'
require_relative '../sycutil/console.rb'
require_relative 'task_service.rb'

module Syctask
  # String that is prompted during planning
  PROMPT_STRING = '(a)dd, (c)omplete, (s)kip, (q)uit: '
  # String that is prompted during prioritization
  PRIORITIZE_STRING = 'Task 1 has (h)igher or (l)ower priority, or (q)uit: '

  # A TaskPlanner prompts the user to select tasks for today. These tasks can
  # be prioritized to determine the most to the least important tasks.
  class TaskPlanner
    # The task where the planned tasks are saved to
    WORK_DIR = File.expand_path("~/.tasks")

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
      already_planned = self.get_tasks(date)
      count = 0
      re_display = false
      planned = []
      tasks.each do |task|
        next if already_planned.find_index {|t| t == task}
        unless re_display
          task.print_pretty
        else
          task.print_pretty(true)
          re_display = false
        end
        choice = @console.prompt PROMPT_STRING
        case choice
        when 'a'
          print "Duration (1 = 15 minutes, return 30 minutes): "
          duration = gets.chomp
          task.duration = duration.empty? ? 2 : duration
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

    # Moves the specified tasks to the specified date. Returns the count of
    # moved files
    def move_tasks(filter={}, from_date=Time.now.strftime("%Y-%m-%d"), to_date)
      return 0 if from_date == to_date
      moved = get_tasks(from_date, filter)
      moved.each do |task| 
        task.options[:follow_up] = to_date
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
      end if File.exists? @todo_today_file
      tasks
    end

   private

    # Creates a file where the planned tasks are saved to
    def make_todo_today_file(date)
      file_name = Time.now.strftime("#{date}_planned_tasks")
      @todo_today_file = WORK_DIR+"/"+file_name
    end

    # Save the tasks to a file. If override is true the file is overriden
    # otherwise the tasks are appended
    def save_tasks(tasks, override=false)
      mode = override ? 'w' : 'a'
      FileUtils.mkdir_p WORK_DIR unless File.exists? WORK_DIR
      File.open(@todo_today_file, mode) do |file|
        tasks.each do |task|
          file.puts("#{task.dir},#{task.id}")
        end 
      end
    end

  end

end
