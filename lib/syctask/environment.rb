module Syctask

  # Default working directory of the application
  WORK_DIR = File.expand_path('~/.tasks')
  SYC_DIR = File.expand_path('~/.syc/syctask')
  ID = SYC_DIR + "/id"
  IDS = SYC_DIR + "/ids"
  TAGS = SYC_DIR + "/tags"
  DEFAULT_TASKS = SYC_DIR + "/default_tasks"
  TASKS_LOG = SYC_DIR + "/tasks.log"
  TRACKED_TASK = SYC_DIR + "/tracked_tasks"
  RIDX_LOG = SYC_DIR + "/reindex.log"

  def log_task(type, task)
    File.open(TASKS_LOG, 'a') do |file|
      log_entry =  "#{type.to_s};"
      log_entry += "#{task.id};#{task.dir};"
      log_entry += "#{task.title.gsub(';', '\'semicolon\'')};"
      log_entry += "#{Time.now};"
      log_entry += "#{Time.now}" 
      file.puts log_entry
    end
  end

  def check_environment
    FileUtils.mkdir_p WORK_DIR unless File.exists? WORK_DIR
    unless viable?
      unless get_files(File.expand_path("~"), "*.task").empty?
        # Backup ARGV content
        args = []
        ARGV.each {|arg| args << arg} unless ARGV.empty?
        ARGV.clear
        puts
        puts "Warning:"
        puts "-------"
        puts "There are missing system files of syc-task, even though tasks "+
             "are available."
        puts "If you have upgraded from version 0.0.7 or below than this is "+
             "due to a changed\nfile structure. For changes in version "+
             "greater 0.0.7 see"
        puts "--> https://rubygems.org/gems/syc-task"
        puts "Or you have accidentially deleted system files. In both cases "+
             "re-indexing\nwill recover syc-task."
        print "Do you want to recover syc-task (y/n)? "
        answer = gets.chomp
        exit -1 unless answer.downcase == "y"
        reindex_tasks(File.expand_path("~"))
        puts "Successfully recovered syc-task"
        puts "-> A log file of re-indexed tasks can be found at\n"+
             "#{RIDX_LOG}" if File.exists? RIDX_LOG
        print "Press any key to continue "
        gets
        # Restore ARGV content
        args.each {|arg| ARGV << arg} unless args.empty?
      else
        FileUtils.mkdir_p SYC_DIR unless File.exists? SYC_DIR
        File.write(ID, "0")
      end
    end
  end

  # Checks if system files are available that are needed for running syc-task.
  # Returns true if neccessary system files are available, otherwise false.
  def viable?
    File.exists? SYC_DIR and File.exists? ID 
  end

  # Re-indexing of tasks is done when tasks are available but SYC_DIR or ID file
  # is missing. The ID file contains the last issued task ID. The ID file is
  # referenced for obtaining the next ID for a new task. Re-indexing is done as
  # follows:
  # * Retrieve all tasks in and below the given directory *root*
  # * Determine the highest ID number and add it to the ID file
  # * Determine all tasks that don't have a unique ID
  # * Re-index all tasks not having a unique ID and rename the file names
  #   accordingly
  # * Adjust the IDs in the planned_tasks, tasks.log and tracked_tasks files
  # * Copy all system files planned_tasks, time_schedule, tasks.log, id to the
  #   SYC_DIR directory if not already in the SYC_DIR directory. This should
  #   only be if upgrading from version 0.0.7 and below.
  def reindex_tasks(root)
    FileUtils.mkdir_p SYC_DIR unless File.exists? SYC_DIR
    new_id = {}
    to_be_renamed = {}
    root = File.expand_path(root)
    puts "-> Collect task files..."
    task_files = task_files(root)
    puts "-> Restore ID counter..."
    initialize_id(task_files)
    print "-> Start re-indexing now..."
    collect_by_id(task_files).each do |id, files|
      next if files.size < 2
      files.each_with_index do |file,i|
        next if i == 0 # need to re-index only second and following tasks
        result = reindex_task(file)
        # associate old id to new id and dir name
        if new_id[result[:old_id]].nil?
          new_id[result[:old_id]] = {result[:dirname] => result[:new_id]}
        else
          new_id[result[:old_id]][result[:dirname]] = result[:new_id]
        end 
        # assign tmp_file to new_file for later renaming
        to_be_renamed[result[:tmp_file]] = result[:new_file]
        # document the re-indexing of tasks
        log_reindexing(result[:old_id], result[:new_id], result[:new_file]) 
      end
    end 
    to_be_renamed.each {|old_name,new_name| File.rename(old_name, new_name)}
    puts
    puts "-> Update task log file"
    update_tasks_log(root, new_id)
    puts "-> Update planned tasks files"
    update_planned_tasks(root, new_id)
    puts "-> Move schedule files..."
    move_time_schedule_files(root)
    puts "-> Update tracked task file..."
    update_tracked_task(root)
  end

  # Re-indexes the tasks' IDs and renames the task files to match the new ID.
  # The orginal file is deleted. Returns old_id, new_id, tmp_file_name and
  # new_file_name. The task is save with the tmp_file_name in case the new ID
  # and hence the new_file_name exists already from a not yet re-indexed task.
  # After all tasks are re-indexed the tmp_file_names have to be renamed to the
  # new_file_names. The renaming is in the responsibility of the calling method.
  def reindex_task(file)
    print "."
    task = File.read(file)
    old_id = task.scan(/(?<=^id: )\d+$/)[0]
    new_id = next_id.to_s
    task.gsub!(/(?<=^id: )\d+$/, new_id)
    dirname = File.dirname(file)
    new_file = "#{dirname}/#{new_id}.task"
    tmp_file = "#{new_file}_"
    File.write(tmp_file, task)
    File.delete(file)
    {old_id: old_id, 
     new_id: new_id, 
     tmp_file: tmp_file, 
     new_file: new_file,
     dirname: dirname}
  end

  # Determines the greatest task ID out of the provided tasks and saves it to
  # the ID file
  def initialize_id(tasks)
    pattern = %r{(?<=\/)\d+(?=\.task)}
    tasks.sort_by! {|t| t.scan(pattern)[0].to_i}
    save_id(tasks[tasks.size-1].scan(pattern)[0].to_i)
  end

  def save_ids(id, file)
    entry = "#{id},#{file}"
    return if File.exists? IDS and not File.read(IDS).scan(entry).empty?
    File.open(IDS, 'a') {|f| f.puts entry}
  end

  # Save the id to the ID file. Returns the id when save was successful
  def save_id(id)
    File.write(ID,id)
    id
  end

  # Retrieve the next unassigned task id
  def next_id
    id = File.read(ID).to_i + 1
    save_id(id)
    id
  end

  def log_reindexing(old_id, new_id, file)
    entry = "#{old_id},#{new_id},#{file}"
    return if File.exists? RIDX_LOG and not File.read(RIDX_LOG).
      scan(entry).empty?
    File.open(RIDX_LOG, 'a') {|f| f.puts entry}
  end

  def update_tasks_log(dir, new_ids)
    tasks_log_files(dir).each do |file|
      logs = File.readlines(file)
      logs.each_with_index do |log,i|
        type = log.scan(/^.*?(?=;)/)[0]
        logs[i] = log.sub!("-",";") if log.scan(/(?<=^#{type};)\d+-/)[0]
        old_id = log.scan(/(?<=^#{type};)\d+(?=;)/)[0]
        next unless new_ids[old_id]
        task_dir = log.scan(/(?<=^#{type};#{old_id};).*?(?=;)/)[0]
        next unless new_ids[old_id][task_dir]
        logs[i] = log.sub("#{old_id};#{task_dir}", 
                          "#{new_ids[old_id][task_dir]};#{task_dir}")
      end
      if file == TASKS_LOG
        File.write(TASKS_LOG, logs.join)
      else
        #TODO only append a line if it is not already available in TASKS_LOG
        File.open(TASKS_LOG, 'a') {|f| f.puts logs.join}
        FileUtils.rm file
      end
    end
  end

  def update_tasks_log_old(dir, old_id, new_id, file)
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
  def update_planned_tasks(dir, new_ids)
    planned_tasks_files(dir).each do |file|
      tasks = File.readlines(file)
      tasks.each_with_index do |task,i|
        task_dir, old_id = task.chomp.split(',')
        next unless new_ids[old_id]
        next unless new_ids[old_id][task_dir]
        tasks[i] = "#{task_dir},#{new_ids[old_id][task_dir]}"   
      end
      File.write("#{SYC_DIR}/#{File.basename(file)}", tasks.join("\n"))
    end
  end

  def update_planned_tasks_old(dir, old_id, new_id, file)
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
    if File.exists? RIDX_LOG
      old_id = task.scan(/(?<=id: )\d+$/)
      old_dir = task.scan(/(?<=dir: ).*$/)
      return if old_id.empty? or old_dir.empty?
      pattern = %r{(?<=#{old_id[0]},)\d+(?=,#{old_dir[0]}\/\d+\.task)}
      new_id = File.read(RIDX_LOG).scan(pattern)
      task.gsub!("id: #{old_id}", "id: #{new_id}")
    end
    File.write(TRACKED_TASK, task)
    FileUtils.rm @tracked[0] unless TRACKED_TASK == @tracked[0]
  end

  # Extracts tasks that have no unique id
  def collect_by_id(tasks)
    extract = {}
    tasks.each do |task|
      id = task.scan(/(?<=\/)\d+(?=\.task$)/)[0]
      extract[id].nil? ? extract[id] = [task] : extract[id] << task
    end
    extract
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
