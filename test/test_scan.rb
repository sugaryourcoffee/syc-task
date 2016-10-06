require 'minitest/autorun'
require 'shoulda'
require_relative '../lib/syctask/scanner'

# Tests for the Scan
class TestScan < Minitest::Test

  context "Scan" do

    # Backup system files
    def setup
      backup_system_files("TestTask")
    end

    # Restore system files
    def teardown
      restore_system_files("TestTask")
    end

    should "create task fields from a string separated with ;" do
      content = <<-HEREDOC
      This is text that should be ignored
      @tasks;
      title;description;prio;due_date;follow_up
      Title1;Description1;1;2016-09-10;2016-09-11
      Title2;Description2;2;2016-09-20;2016-09-21

      This is text that should be ignored
      HEREDOC

      scanner = Scanner.new
      tasks = scanner.scan(content)
      assert_equal 2, tasks.size

      tasks.each_with_index do |(title, options), i|
        i += 1
        assert_equal "Title#{i}", title
        assert_equal [:description, :prio, :due_date, :follow_up], options.keys
        assert_equal ["Description#{i}", "#{i}", 
                      "2016-09-#{i}0", "2016-09-#{i}1"], options.values
      end
    end

    should "create task fields with spaces between separators" do
      content = <<-HEREDOC
      This is text that should be ignored
      @tasks;
      Title ; Description ; Prio ; Due_Date ; Follow_Up
      Title1 ; Description1 ; 1 ; 2016-09-10 ; 2016-09-11
      Title2 ; Description2 ; 2 ; 2016-09-20 ; 2016-09-21

      This is text that should be ignored
      HEREDOC

      scanner = Scanner.new
      tasks = scanner.scan(content)
      assert_equal 2, tasks.size

      tasks.each_with_index do |(title, options), i|
        i += 1
        assert_equal "Title#{i}", title
        assert_equal [:description, :prio, :due_date, :follow_up], options.keys
        assert_equal ["Description#{i}", "#{i}", 
                      "2016-09-#{i}0", "2016-09-#{i}1"], options.values
      end
    end

    should "throw error if title column value is missing" do
      content = <<-HEREDOC
      This is text that should be ignored
      @tasks;
      Topic ; Description ; Prio ; Due_Date ; Follow_Up
      Title1 ; Description1 ; 1 ; 2016-09-10 ; 2016-09-11
      Title2 ; Description2 ; 2 ; 2016-09-20 ; 2016-09-21

      This is text that should be ignored
      HEREDOC

      assert_raises ArgumentError do
        Scanner.new.scan(content)
      end
    end

    should "create task from string in markdown notation" do
      content = <<-HEREDOC
      This is text that should be ignored
      And here we go with markdown
      @tasks|
      title |description |prio|due_date  |follow_up
      ------|------------|----|----------|----------
      Title1|Description1|1   |2016-09-10|2016-09-11
      Title2|Description2|2   |2016-09-20|2016-09-21
      Title3|Description3|3   |2016-09-30|2016-09-31

      This is text that should be ignored
      HEREDOC

      scanner = Scanner.new
      tasks = scanner.scan(content)
      assert_equal 3, tasks.size

      tasks.each_with_index do |(title, options), i|
        i += 1
        assert_equal "Title#{i}", title
        assert_equal [:description, :prio, :due_date, :follow_up], options.keys
        assert_equal ["Description#{i}", "#{i}", 
                      "2016-09-#{i}0", "2016-09-#{i}1"], options.values
      end

    end

    should "create tasks from string with multiple annotations" do
      content = <<-HEREDOC
      This is text that should be ignored
      And here we go with markdown
      @TaSks|
      title |description |prio|due_date  |follow_up
      ------|------------|----|----------|----------
      Title1|Description1|1   |2016-09-10|2016-09-11
      Title2|Description2|2   |2016-09-20|2016-09-21

      This is text that should be ignored
      And no we go with on task ommitting the task fields using those from
      before
      @task;
      Title3;Description3;3;2016-09-30;2016-09-31
      Titlex;Descriptionx;x;2016-09-10;2016-09-11
      The Titlex should not be scanned
      But we go now again for @tasks
      @tasks;
      Title4;Description4;4;2016-09-40;2016-09-41
      Title5;Description5;5;2016-09-50;2016-09-51
      And some other text that separates from following tasks
      Title6;Description6;6;2016-09-60;2016-09-61

      And here is the end 
      HEREDOC

      scanner = Scanner.new
      tasks = scanner.scan(content)
      assert_equal 6, tasks.size

      tasks.each_with_index do |(title, options), i|
        i += 1
        assert_equal "Title#{i}", title
        assert_equal [:description, :prio, :due_date, :follow_up], options.keys
        assert_equal ["Description#{i}", "#{i}", 
                      "2016-09-#{i}0", "2016-09-#{i}1"], options.values
      end

    end

  end
end
