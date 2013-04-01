require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/task_service.rb'
require_relative '../lib/syctask/task_planner.rb'

# Tests for the TaskPlanner class
class TestTaskPlanner < Test::Unit::TestCase

  context "TaskPlanner" do
    
    # Sets up the test and initializes variables used in the tests
    def setup
      backup_system_files("TestTaskPlanner")
      @plan_date = '2013-03-01'
      @planned_tasks_file = File.
                            expand_path("~/.tasks/#{@plan_date}_planned_tasks")
      @service = Syctask::TaskService.new
      @planner = Syctask::TaskPlanner.new
      @dir = "test/tasks"
      FileUtils.mkdir_p @dir unless File.exists? @dir
      1..5.times do |i|
        options = {descriptions: "Description of task #{i+1}",
                   follow_up: '2013-03-02', due: '2013-04-02', prio: i+1,
                   note: "Note of task #{i+1}", tags: "tag#{i+1},tag#{i+2}"}
        @service.create(@dir, options, "Title of task number #{i+1}")
      end
    end

    # Removes files and directories created during the tests
    def teardown
      restore_system_files("TestTaskPlanner")
      FileUtils.rm_r @dir if File.exists? @dir
      FileUtils.rm @planned_tasks_file if File.exists? @planned_tasks_file
    end

    should "plan tasks listing all tasks" do
      tasks = @service.find(@dir, {}, false)
      assert_equal 5, tasks.size
      count = @planner.plan_tasks(tasks, @plan_date)
      assert count > -1
    end

    should "plan tasks listing filtered tasks" do
      filter = {id: "2,3"}
      tasks = @service.find(@dir, filter, false)
      assert_equal 2, tasks.size
      count = @planner.plan_tasks(tasks, @plan_date)
      assert count > -1
    end

    should "show planned tasks" do
      tasks = @planner.get_tasks(@plan_date, {})
      assert_equal 0, tasks.size 
      tasks = @service.find(@dir, {id: "4,5"}, false)
      count = @planner.plan_tasks(tasks, @plan_date)
      assert_equal count, @planner.get_tasks(@plan_date, {}).size
    end
    
    should "remove planned tasks" do
      tasks = @service.find(@dir, {id: "3,4,5"}, false)
      count = @planner.plan_tasks(tasks, @plan_date)
      if count > 0
        tasks = @planner.get_tasks(@plan_date, {})
        ids = []
        tasks.each {|task| ids << task.id}
        removed = @planner.remove_tasks(@plan_date, {id: ids.join(',')})
        assert_equal count, removed
      else
        assert true
      end
    end

    # A scenario would be to have Task 1 to 5 prioritized to have a result of
    # * Task 1
    # * Task 3
    # * Task 5
    # * Task 4
    # * Task 2
    should "prioritize tasks" do
      puts "\nTest prioritize tasks"
      puts "---------------------"
      tasks = @service.find(@dir, {}, false)
      @planner.plan_tasks(tasks, @plan_date)     
      @planner.prioritize_tasks(@plan_date, {})
    end

  end

end
