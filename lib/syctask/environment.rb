module Syctask

  WORK_DIR = File.expand_path('~/.tasks')
  SYC_DIR = File.expand_path('~/.syc/syctask')
  ID = SYC_DIR + "/id"
  IDS = SYC_DIR + "/ids"
  TAGS = SYC_DIR + "/tags"
  DEFAULT_TASKS = SYC_DIR + "/default_tasks"
  TASKS_LOG = SYC_DIR + "/tasks.log"
  TRACKED_TASK = SYC_DIR + "/tracked_tasks"
  RIDX_LOG = SYC_DIR + "/reindex.log"

  def check_environment
    FileUtils.mkdir_p WORK_DIR unless File.exists? WORK_DIR
    unless viable?
      unless get_files(File.expand_path("~"), "*.task").empty?
        puts "Warning:"
        puts "------"
        puts "There are missing system files of syctask, even though tasks are"
        puts "available."
        puts "If you have upgraded from a version less than 0.1.0 than you may"
        puts "re-index your tasks. For details see"
        puts "http://rubygems.org/sugaryourcoffee syc-task 0.1.0"
        puts "Or you have accidentially deleted system files. In this case also"
        puts "re-indexing will fix it."
        print "Re-index your tasks (y/n)? "
        answer = gets.chomp
        exit -1 if answer.downcase == "n"
        print "Re-indexing now"
        reindex_tasks(File.expand_path("~"))
        puts "Successfully re-indexed your tasks"
        puts "A log file of re-indexed tasks can be found at #{RIDX_LOG}"
      else
        FileUtils.mkdir_p SYC_DIR unless File.exists? SYC_DIR
        File.write(ID, "0")
      end
    end
  end

  def viable?
    File.exists? SYC_DIR and File.exists? ID 
  end

  def reindex_tasks(root)
    FileUtils.mkdir_p SYC_DIR unless File.exists? SYC_DIR
    id = 0
    to_be_renamed = {}
    root = File.expand_path(root)
    @task_files = task_files(root) if @task_files.nil?
    @task_files.each_with_index do |file,index|
      id = index + 1
      result = reindex_task(root, file, id)
      # assign tmp_file to new_file for later renaming
      to_be_renamed[result[:tmp_file]] = result[:new_file]
      # write new_id, path to IDS
      save_ids(result[:new_id], result[:new_file])
      # write old_id, new_id, path to index.log
      log_reindexing(result[:old_id], result[:new_id], result[:new_file]) 
      # replace old_id with new_id in task.log
      update_tasks_log(root, 
                       result[:old_id], 
                       result[:new_id], 
                       result[:new_file])
      # replace old_id with new_id in planned_tasks
      update_planned_tasks(root, 
                           result[:old_id], 
                           result[:new_id], 
                           result[:new_file])
    end 
    to_be_renamed.each {|old_name,new_name| File.rename(old_name, new_name)}
    move_task_log_file(root)
    move_planned_tasks_files(root)
    move_time_schedule_files(root)
    update_tracked_task(root)
    save_id(id)
  end

  # Re-indexes the tasks' IDs and renames the task files to match the new ID.
  # The orginal file is deleted. Returns old_id, new_id, tmp_file_name and
  # new_file_name. The task is save with the tmp_file_name in case the new ID
  # and hence the new_file_name exists already from a not yet re-indexed task.
  # After all tasks are re-indexed the tmp_file_names have to be renamed to the
  # new_file_names. The renaming is in the responsibility of the calling method.
  def reindex_task(root, file, index)
    print "."
    task = File.read(file)
    old_id = task.scan(/(?<=^id: )\d+$/)[0]
    new_id = (index).to_s
    task.gsub!(/(?<=^id: )\d+$/, new_id)
    new_file = "#{File.dirname(file)}/#{new_id}.task"
    tmp_file = "#{new_file}_"
    File.write(tmp_file, task)
    File.delete(file)
    {old_id: old_id, new_id: new_id, tmp_file: tmp_file, new_file: new_file}
  end

  def save_ids(id, file)
    entry = "#{id},#{file}"
    return if File.exists? IDS and not File.read(IDS).scan(entry).empty?
    File.open(IDS, 'a') {|f| f.puts entry}
  end

  def save_id(id)
    File.write(ID,id)
  end

  def log_reindexing(old_id, new_id, file)
    entry = "#{old_id},#{new_id},#{file}"
    return if File.exists? RIDX_LOG and not File.read(RIDX_LOG).
      scan(entry).empty?
    File.open(RIDX_LOG, 'a') {|f| f.puts entry}
  end

  def update_tasks_log(dir, old_id, new_id, file)
    old_entry = "#{old_id}-#{File.dirname(file)}"
    # Append '/' to dir name so already updated task is not subsequently updated
    new_entry = "#{new_id}-#{File.dirname(file)}/"
    @tasks_log_files = tasks_log_files(dir) if @tasks_log_files.nil?
    @tasks_log_files.each do |f|
      tasks_log = File.read(f).gsub(old_entry, new_entry)
      File.write(f, tasks_log)
    end
  end

  # Replaces the old ids with the new ids in the planned tasks files. A planned
  # tasks file has the form '2013-03-03_planned_tasks' and lives until syctask's
  # version 0.0.7 in ~/.tasks directory. From version 0.1.0 on the planned tasks
  # files live in the ~/.syc/syctask directory. So the calling method has the
  # responsibility to copy or move the planned tasks files after they have been
  # updated to the new planned tasks directory.
  def update_planned_tasks(dir, old_id, new_id, file)
    old_entry = "#{File.dirname(file)},#{old_id}"
    # Append '/' to dir name so already updated task is not subsequently updated
    new_entry = "#{File.dirname(file)}/,#{new_id}"
    @planned_tasks_files = planned_tasks_files(dir) if @planned_tasks_files.nil?
    @planned_tasks_files.each do |file|
      planned_tasks = File.read(file).gsub(old_entry, new_entry)
      File.write(file, planned_tasks)
    end
  end

  def update_tracked_task(dir)
    @tracked = get_files(dir, "tracked_tasks") if @tracked.nil?
    return if @tracked.empty?
    task = File.read(@tracked[0])
    old_id = task.scan(/(?<=id: )\d+$/)
    old_dir = task.scan(/(?<=dir: ).*$/)
    puts "#{old_id} #{old_dir}"
    return if old_id.empty? or old_dir.empty?
    pattern = %r{(?<=#{old_id[0]},)\d+(?=,#{old_dir[0]}\/\d+\.task)}
    puts pattern
    new_id = File.read(RIDX_LOG).scan(pattern)
    puts "new_id = #{new_id}<"
    task.gsub!("id: #{old_id}", "id: #{new_id}")
    puts task
    File.write(TRACKED_TASK, task)
    FileUtils.rm @tracked[0] unless TRACKED_TASK == @tracked[0]
  end

  # Retrieves all task files in and below the provided dir. Returns an array of
  # task files
  def task_files(dir)
    get_files(dir, "*.task").keep_if {|file| file.match /\d+\.task$/}
  end

  def planned_tasks_files(dir)
    pattern = %r{\d{4}-\d{2}-\d{2}_planned_tasks}
    get_files(dir, "*planned_tasks").keep_if {|f| f.match(pattern)}
  end

  def time_schedule_files(dir)
    pattern = %r{\d{4}-\d{2}-\d{2}_time_schedule}
    get_files(dir, "*time_schedule").keep_if {|f| f.match(pattern)}
  end

  def tasks_log_files(dir)
    get_files(dir, "tasks.log")
  end

  def get_files(dir, pattern)
    original_dir = File.expand_path(".")
    Dir.chdir(dir)
    files = Dir.glob("**/#{pattern}", File::FNM_DOTMATCH).map do |f|
      File.expand_path(f)
    end
    Dir.chdir(original_dir)
    files
  end

  def move_task_log_file(dir)
    @tasks_log_files = tasks_log_files(dir) if @tasks_log_files.nil?
    @tasks_log_files.each do |f|
      next if f == TASKS_LOG
      tasks_log = File.read(f)
      File.open(TASKS_LOG, 'a') {|t| t.puts tasks_log}
      FileUtils.mv(f, "#{f}_#{Time.now.strftime("%y%m%d")}")
    end
  end

  def move_planned_tasks_files(dir)
    @planned_tasks_files = planned_tasks_files(dir) if @planned_tasks_files.nil?
    @planned_tasks_files.each do |file|
      to_file = "#{SYC_DIR}/#{File.basename(file)}"
      next if file == to_file
      FileUtils.mv file, to_file
    end
  end

  def move_time_schedule_files(dir)
    @time_schedule_files = time_schedule_files(dir) if @time_schedule_files.nil?
    @time_schedule_files.each do |file|
      to_file = "#{SYC_DIR}/#{File.basename(file)}" 
      next if file == to_file
      FileUtils.mv file, to_file
    end 
  end

end
