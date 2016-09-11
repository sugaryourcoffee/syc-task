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

    should "create task fields from a string" do
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

    should "create task from file with all fields" do
    end

    should "create task from file with last fields omitted" do
    end

    should "create task from file with intermediate fields omitted" do
    end

    should "create task from file with intermediate and last fields omitted" do
    end

  end
end
