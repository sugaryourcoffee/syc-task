require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/environment.rb'
require_relative '../lib/syctask/task_service.rb'
include Syctask

class TestEnvironment < Test::Unit::TestCase

  context "Test re-indexing helpers" do
    
    def setup
      backup_system_files
      @time = Time.now
      @work_dir = "test/tasks"
      @service = Syctask::TaskService.new
      FileUtils.mkdir @work_dir unless File.exists? @work_dir
      1.upto(10) do |i|
        @service.create(@work_dir, {}, "task number #{i}")
      end
      1.upto(5) do |i|
        @service.create("#{@work_dir}/sub", {}, "task Number #{i}")
      end
      1.upto(3) do |i|
        FileUtils.touch "#{@work_dir}/2013-0#{i}-17_planned_tasks"
        FileUtils.touch "#{@work_dir}/2013-0#{i}-17_time_schedule"
      end
      FileUtils.touch "#{@work_dir}/tasks.log"
      FileUtils.touch "#{@work_dir}/tracked_tasks"
    end

    def teardown
      restore_system_files
      FileUtils.rm_r @work_dir if File.exists? @work_dir
    end

    def backup_system_files
      system_files = Dir.glob("#{Syctask::SYC_DIR}/*")
      system_files.each do |f|
        FileUtils.mv f, f + ".original"
        FileUtils.touch f
      end
    end

    def restore_system_files
      Dir.glob("#{Syctask::SYC_DIR}/*").each do |f|
        if f.end_with? ".original" 
          FileUtils.mv f, f.sub(".original", "") 
        else
          FileUtils.rm f 
        end
      end
    end

    # Fills the log file with entries and returns these in a hash
    def make_log_file
      tasks = {}
      "a".upto("b") do |j|
        1.upto(10) do |i|
          tasks["#{j}#{i}"] = {id:       i,
                               title:    "Task #{i}",
                               new_id:   i+100, 
                               dir:      "test/tasks/#{j}", 
                               file:     "test/tasks/#{j}/#{i}.task",
                               new_file: "test/tasks/#{j}/#{i+100}.task"}
        end
      end
      File.open("#{@work_dir}/tasks.log", 'w') do |f|
        tasks.each do |k,v|
          f.puts "start;#{v[:id]}-#{v[:dir]};#{v[:title]};#{@time};"
          f.puts "stop;#{v[:id]}-#{v[:dir]};#{v[:title]};#{@time};#{@time}"
        end
      end
      tasks
    end

    def create_tracked_tasks_file
      File.open("#{@work_dir}/tracked_tasks", 'w') do |f|
        f.puts("---")
        f.puts("- !ruby/object:Syctask::Track")
        f.puts("  dir: /home/pierre/.tasks")
        f.puts("  id: 68")
        f.puts("  title: Add unique ID to tasks")
        f.puts("  started: 2013-03-30 11:54:59 +01:00")
      end
    end

    def create_reindex_log_file
      File.open(Syctask::RIDX_LOG, 'w') do |f|
        f.puts "33,68,/home/pierre/.tasks/68.task"
        f.puts "22,57,/home/pierre/.tasks/57.task"
        f.puts "88,99,/home/pierre/.tasks/99.task"
        f.puts "68,22,/home/pierre/.tasks/22.task"
      end
    end

    should "retrieve files via get_files" do
      current_dir = File.expand_path(".")
      tasks = Syctask::get_files(@work_dir, "*.task")
      assert_equal 15, tasks.size
      assert_equal current_dir, File.expand_path(".")
    end

    should "retrieve task files" do
      current_dir = File.expand_path(".")
      tasks = Syctask::task_files(@work_dir)
      assert_equal 15, tasks.size
      assert_equal current_dir, File.expand_path(".")
    end

    should "initialize max id" do
      tasks = Syctask::task_files(@work_dir)
      Syctask::initialize_id(tasks)
      assert_equal 15, File.read(Syctask::ID).chomp.to_i
    end

    should "get next id" do
      Syctask::initialize_id(Syctask::task_files(@work_dir))
      assert_equal 16, Syctask::next_id
      assert_equal 17, Syctask::next_id
    end

    should "retrieve tasks.log" do
      log = Syctask::tasks_log_files(@work_dir)
      assert_equal 1, log.size
    end

    should "retrieve planned_tasks files" do
      planned = Syctask::planned_tasks_files(@work_dir)
      assert_equal 3, planned.size
    end

    should "retrieve time_schedule files" do
      scheduled = Syctask::time_schedule_files(@work_dir)
      assert_equal 3, scheduled.size
    end

    should "re-index tasks" do
      tasks = Syctask::task_files(@work_dir)
      index = tasks.size 
      tasks.each do |f|
        index += 1
        result = reindex_task(f)
        assert_equal index, result[:new_id].to_i
        assert File.basename(f).start_with? result[:old_id]
        refute File.exists? f
        assert File.exists? result[:tmp_file] 
        assert_equal "#{File.dirname(f)}/#{index}.task", result[:new_file]
      end 
    end

    should "add index to IDS" do
      tasks = Syctask::task_files(@work_dir)
      2.times do
        tasks.each do |f|
          Syctask::save_ids(File.basename(f).scan(/\d+(?=\.task)/)[0], f)
        end
        puts "Tasks.size = #{tasks.size}"
        puts "ids.size = #{File.readlines(Syctask::IDS).size}"
        assert_equal tasks.size, File.readlines(Syctask::IDS).size 
      end
    end

    should "add entry to reindexing log" do
      tasks = Syctask::task_files(@work_dir)
      tasks.each_with_index do |f,i|
        index = i + 100
        result = reindex_task(f)
        puts result.inspect
        Syctask::log_reindexing(result[:old_id], 
                                result[:new_id], 
                                result[:new_file])
      end 
      assert_equal tasks.size, File.readlines(Syctask::RIDX_LOG).size
    end

    should "update planned tasks" do
      tasks = Syctask::task_files(@work_dir)
      planned = Syctask::planned_tasks_files(@work_dir)
      planned.each_with_index do |f,i|
        File.open(f, 'w') do |f|
          f.puts "work/tasks,1"
          f.puts "work/tasks,2"
        end
      end
      1.upto(2) do |i|
        Syctask::update_planned_tasks(@work_dir, 
                                      i, 
                                      i+100, 
                                      "work/tasks/#{i+100}.task")
      end
      planned.each do |p|
        File.open(p, 'r').each_with_index do |line,i|
          expected = "work/tasks/,#{i+1+100}\n"
          assert_equal expected, line
        end
      end
    end

    should "update tasks log" do
      tasks = make_log_file

      tasks.each do |k,v|
        Syctask::update_tasks_log(@work_dir, 
                                  v[:id], 
                                  v[:new_id],
                                  v[:new_file])
      end

      v = tasks.values
      c = 0
      File.open("#{@work_dir}/tasks.log", 'r').each_with_index do |line,i|
        if i % 2 == 1
          c += 1
          expected =  "stop;"
          expected += "#{v[i-c][:new_id]}-#{v[i-c][:dir]}/;#{v[i-c][:title]};"
          expected += "#{@time};#{@time}\n"
        else
          expected =  "start;"
          expected += "#{v[i-c][:new_id]}-#{v[i-c][:dir]}/;#{v[i-c][:title]};"
          expected += "#{@time};\n" 
        end
        assert_equal expected, line
      end
    end

    should "update tracked task" do
      create_tracked_tasks_file
      create_reindex_log_file
      Syctask::update_tracked_task(@work_dir)
      refute File.exists? "#{@work_dir}/tracked_tasks"
      assert File.exists? Syctask::TRACKED_TASK
      assert File.read(Syctask::TRACKED_TASK).scan(/id: 68/)
    end

    should "move task log file" do
      tasks = make_log_file
      assert File.exists? "#{@work_dir}/tasks.log"
      Syctask::move_task_log_file(@work_dir)
      refute File.exists? "#{@work_dir}/tasks.log"
      assert File.exists? Syctask::TASKS_LOG
    end

    should "move planned task files" do
      1.upto(3) do |i|
        assert File.exists? "#{@work_dir}/2013-0#{i}-17_planned_tasks"
      end
      Syctask::move_planned_tasks_files(@work_dir)
      1.upto(3) do |i|
        file = "2013-0#{i}-17_planned_tasks"
        refute File.exists? "#{@work_dir}/#{file}"
        assert File.exists? "#{Syctask::SYC_DIR}/#{file}"
      end
    end

    should "move time schedule files" do
      1.upto(3) do |i|
        assert File.exists? "#{@work_dir}/2013-0#{i}-17_time_schedule"
      end
      Syctask::move_time_schedule_files(@work_dir)
      1.upto(3) do |i|
        file = "2013-0#{i}-17_time_schedule"
        refute File.exists? "#{@work_dir}/#{file}"
        assert File.exists? "#{Syctask::SYC_DIR}/#{file}"
      end
    end

  end

end
