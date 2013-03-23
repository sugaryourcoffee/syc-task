module Syctask

  WORK_DIR = File.expand_path('~/.tasks')
  SYC_DIR = File.expand_path('~/.syc/syctask')
  ID = SYC_DIR + "/id"
  IDS = SYC_DIR + "/properties/ids"
  TAGS = SYC_DIR + "/tags"
  DEFAULT_TASKS = SYC_DIR + "/default_tasks"

  def make_environment
    FileUtils.mkdir_p WORK_DIR unless File.exists? WORK_DIR
    FileUtils.mkdir_p SYC_DIR unless File.exists? SYC_DIR
  end

end
