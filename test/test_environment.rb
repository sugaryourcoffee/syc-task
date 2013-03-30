require 'test/unit'
require 'shoulda'
require_relative '../lib/syctask/environment.rb'
require_relative '../lib/syctask/task_service.rb'
include Syctask

class TestEnvironment < Test::Unit::TestCase

  context "Test re-indexing helpers" do

    def setup
      backup_system_files
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
      FileUtils.touch "#{@work_dir}/tracked_files"
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
      Dir.glob("#{Syctask::SYC_DIR}/*.original").each do |f|
        FileUtils.mv f, f.sub(".original", "")
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
      tasks = Syctask::get_all_task_files(@work_dir)
      assert_equal 15, tasks.size
      assert_equal current_dir, File.expand_path(".")
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
      tasks = Syctask::get_all_task_files(@work_dir)
      tasks.each_with_index do |f,i|
        index = i + 100
        result = reindex_task(@work_dir, f, index)
        assert_equal index, result[:new_id].to_i
        assert File.basename(f).start_with? result[:old_id]
        refute File.exists? f
        assert File.exists? result[:tmp_file] 
        assert_equal "#{File.dirname(f)}/#{index}.task", result[:new_file]
      end 
    end

    should "add index to IDS" do
      tasks = Syctask::get_all_task_files(@work_dir)
      2.times do
        tasks.each do |f|
          Syctask::save_index(File.basename(f).scan(/\d+(?=\.task)/)[0], f)
        end
        puts "Tasks.size = #{tasks.size}"
        puts "ids.size = #{File.readlines(Syctask::IDS).size}"
        assert_equal tasks.size, File.readlines(Syctask::IDS).size 
      end
    end

    should "add entry to reindexing log" do
      tasks = Syctask::get_all_task_files(@work_dir)
      tasks.each_with_index do |f,i|
        index = i + 100
        result = reindex_task(@work_dir, f, index)
        puts result.inspect
        Syctask::log_reindexing(result[:old_id], 
                                result[:new_id], 
                                result[:new_file])
      end 
      assert_equal tasks.size, File.readlines(Syctask::RIDX_LOG).size
    end

    should "update planned tasks" do
      tasks = Syctask::get_all_task_files(@work_dir)
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
    end

    should "move task log file" do
    end

    should "move planned task files" do
    end

    should "move time schedule files" do
    end

    should "move tracked tasks file" do
    end

  end

end
