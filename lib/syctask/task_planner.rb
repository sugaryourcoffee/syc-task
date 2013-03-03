require 'fileutils'
require_relative '../sycutil/console.rb'
require_relative 'task_service.rb'

module Syctask
  PROMPT_STRING = '(a)dd, (c)omplete, (s)kip, (q)uit: '

  class TaskPlanner
    WORK_DIR = File.expand_path("~/.tasks")

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
      puts already_planned
      #make_todo_today_file(date)
      count = 0
      re_display = false
      planned = []
      tasks.each do |task|
        puts "#{task.id} #{task.dir}"
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

    # Add the tasks to the planned tasks
    def add_tasks(tasks)
      save_tasks(tasks)
    end

    def get_tasks(date=Time.now.strftime("%Y-%m-%d"), filter={})
      puts "filter #{filter}"
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

    # Save the tasks to a file
    def save_tasks(tasks)
      FileUtils.mkdir_p WORK_DIR unless File.exists? WORK_DIR
      File.open(@todo_today_file, 'a') do |file|
        tasks.each do |task|
          file.puts("#{task.dir},#{task.id}")
        end 
      end
    end

  end

end
