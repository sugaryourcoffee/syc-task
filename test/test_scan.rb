require 'minitest/autorun'
require 'shoulda'
require_relative '../lib/syctask/task'

# Tests for the Scan
class TestTask < Minitest::Test

  context "Scan" do

    # Backup system files
    def setup
      backup_system_files("TestTask")
    end

    # Restore system files
    def teardown
      restore_system_files("TestTask")
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
