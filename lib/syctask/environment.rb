require 'find'

module Syctask

  # System directory of syctask
  SYC_DIR = File.join(ENV['HOME'], '.syc/syctask') # expand_path('~/.syc/syctask')
  # ID file where the last issued ID is saved
  ID = SYC_DIR + "/id"
  # File that contains all issued IDs
  IDS = SYC_DIR + "/ids"
  # File with tags
  TAGS = SYC_DIR + "/tags"
  # File with the general purpose tasks
  DEFAULT_TASKS = SYC_DIR + "/default_tasks"
  # File that holds the default task directory
  DEFAULT_TASKS_DIR = SYC_DIR + "/default_tasks_dir"
  # Log file that logs all activities of syctask like creation of tasks
  TASKS_LOG = SYC_DIR + "/tasks.log"
  # File that holds the tracked task
  TRACKED_TASK = SYC_DIR + "/tracked_tasks"
  # If files are re-indexed during re-indexing these tasks are save here
  RIDX_LOG = SYC_DIR + "/reindex.log"
 
  # Reads the default task directory from the DEFAULT_TASKS_DIR file if it
  # exists. If it exist but doesn't contain a valid directory ~/.tasks is 
  # returned as default tasks directory
  dir = File.read(DEFAULT_TASKS_DIR) if File.exists? DEFAULT_TASKS_DIR
  # User specified default working directory
  work_dir = dir if not dir.nil? and not dir.empty? and File.exists? dir
  # Set eather user defined work directory or default
  WORK_DIR = work_dir.nil? ? File.join(ENV['HOME'], '.tasks') : work_dir

  # Logs a task regarding create, update, done, delete
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

  # Logs the work time
  def log_work_time(type, work_time)
    today  = Time.now
    begins = Time.local(today.year,
                        today.mon,
                        today.day,
                        work_time[0],
                        work_time[1],
                        0)
    ends   = Time.local(today.year,
                        today.mon,
                        today.day,
                        work_time[2],
                        work_time[3],
                        0)
    entry = "#{type};-1;;work;#{begins};#{ends}\n"
    logs = File.read(TASKS_LOG)
    return if logs.scan(entry)[0]
    time_pat = "#{today.strftime("%Y-%m-%d")} \\d{2}:\\d{2}:\\d{2} [+-]\\d{4}"
    pattern = %r{#{type};-1;;work;#{time_pat};#{time_pat}\n}
    log = logs.scan(pattern)[0]
    if log and logs.sub!(log, entry)
      File.write(TASKS_LOG, logs)
    else
      File.open(TASKS_LOG, 'a') {|f| f.puts entry}
    end
  end

  # Logs meeting times
  def log_meetings(type, busy_time, meetings)
    today = Time.now
    logs = File.read(TASKS_LOG)
    time_pat = "#{today.strftime("%Y-%m-%d")} \\d{2}:\\d{2}:\\d{2} [+-]\\d{4}"
    pattern = %r{#{type};-2;;.*?;#{time_pat};#{time_pat}\n}
    logs.gsub!(pattern, "")
    busy_time.each_with_index do |busy,i|
      begins = Time.local(today.year,today.mon,today.day,busy[0],busy[1],0)
      ends   = Time.local(today.year,today.mon,today.day,busy[2],busy[3],0)
      meeting = meetings[i] ? meetings[i] : "Meeting #{i}"
      logs << "#{type};-2;;#{meeting};#{begins};#{ends}\n"
    end
    File.write(TASKS_LOG, logs)
  end

  # Checks whether all files are available that are needed for syctask's
  # operation
  def check_environment
    FileUtils.mkdir_p WORK_DIR unless File.exists? WORK_DIR
    unless viable?
      recover, whitelisted_dirs, blacklisted_dirs = initialize_or_recover_system
      case recover
      when 0
        FileUtils.mkdir_p SYC_DIR unless File.exists? SYC_DIR
        File.write(ID, "0")
      when 1
        # Backup ARGV content
        args = []
        ARGV.each {|arg| args << arg} unless ARGV.empty?
        ARGV.clear
        reindex_tasks(whitelisted_dirs, blacklisted_dirs)
        puts "Successfully recovered syc-task"
        puts "-> A log file of re-indexed tasks can be found at\n"+
             "#{RIDX_LOG}" if File.exists? RIDX_LOG
        print "Press any key to continue "
        gets
        # Restore ARGV content
        args.each {|arg| ARGV << arg} unless args.empty?
      when 2
        puts "o.k. - don't do nothing"
        exit -1
      end
    end
  end

  # Checks if system files are available that are needed for running syc-task.
  # Returns true if neccessary system files are available, otherwise false.
  def viable?
    File.exists? SYC_DIR and File.exists? ID 
  end

  # Asks the user whether this is a fresh install because of missing system
  # files. If it is not a fresh install then this might be because of an upgrade
  # to a version > 0.0.7 or the user accidentally has deleted the system files.
  # If it is a fresh install the system files are created. Otherwise the user
  # can select to search for task files and recover the system.
  # 
  # intialize_or_recover_system #=> recover, whitelisted_dirs, blacklisted_dirs
  # recover = 0 just creates the system files as it is fresh install
  # recover = 1 recover task files
  # recover = 2 abort, don't recover task files
  # whitelisted_dirs = array of directories where to search for task files
  # blacklisted_dirs = array of directories where not to search for task files
  def initialize_or_recover_system
    whitelisted_dirs = []
    blacklisted_dirs = []

    puts "This seems to be a fresh install because there are no system files "+
         "available."
    puts "* If this is a fresh install just hit 'y'. "
    puts "* Otherwise hit 'n' to go to the recovery step."
    print "Is this a fresh install (y/n)? "
    answer = gets.chomp
    if answer.downcase == "y"
      [0, nil, nil]
    else
      puts
      puts "If you have upgraded from version 0.0.7 or below than this is "+
           "due to a changed\nfile structure. For changes in version "+
           "greater 0.0.7 see"
      puts "--> https://rubygems.org/gems/syc-task"
      puts "Or you have accidentially deleted system files. In both cases "+
           "re-indexing\nwill recover syc-task."
      print "Do you want to recover syc-task (y/n)? "
      answer = gets.chomp
      if answer.downcase == "y"
        puts
        puts "If you know where your task files are located then you can "+
             "specify the\ndirectories. Search starts in your home directory."
        print "Do you want to specify the directories (y/n)? "
        answer = gets.chomp
        if answer.downcase == "y"
          puts "Please enter directories, e.g. ~/.my-tasks ~/work-tasks"
          whitelisted_dirs = gets.chomp.split(/\s+/)
                                       .map { |f| File.expand_path(f) }
        else
          puts "You don't want to select task directories. It is adviced to "+
               "exclude mounted \ndirectories as this might take very long to "+
               "search all directories for task files. Also if it is no " +
               "stable connection\n the recovery process might be aborted"
          print "Do you want to exclude directories (y/n)? "
          if answer.downcase == "y"
            puts "Please enter directories, e.g. ~/mount ~/.no-tasks"
            blacklisted_dirs = gets.chomp.split(/\s+/)
                                         .map { |f| File.expand_path(f) }
          else
            whitelisted_dir = [ENV['HOME']]
            puts "Searching directories and all sub-directories starting in\n"+
                 "#{ENV['HOME']}"
          end
        end
        [1, whitelisted_dirs, blacklisted_dirs]
      else
        [2, nil, nil]
      end
    end
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
  def reindex_tasks(dirs, excluded) #root)
    FileUtils.mkdir_p SYC_DIR unless File.exists? SYC_DIR
    new_id = {}
    to_be_renamed = {}
    puts "-> Collect task files..."
    task_files = task_files(dirs, excluded)
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
    update_tasks_log(dirs, excluded, new_id)
    puts "-> Update planned tasks files"
    update_planned_tasks(dirs, excluded, new_id)
    puts "-> Move schedule files..."
    move_time_schedule_files(dirs, excluded)
    puts "-> Update tracked task file..."
    update_tracked_task(dirs, excluded)
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

  # Saves the ids to ids file
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

  # Logs if a task is re-indexed
  def log_reindexing(old_id, new_id, file)
    entry = "#{old_id},#{new_id},#{file}"
    return if File.exists? RIDX_LOG and not File.read(RIDX_LOG).
      scan(entry).empty?
    File.open(RIDX_LOG, 'a') {|f| f.puts entry}
  end

  # Updates the tasks.log file if tasks are re-indexed with the task's new ids
  def update_tasks_log(dirs, excluded=[], new_ids)
    tasks_log_files(dirs, excluded).each do |file|
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

  # Replaces the old ids with the new ids in the planned tasks files. A planned
  # tasks file has the form '2013-03-03_planned_tasks' and lives until syctask's
  # version 0.0.7 in ~/.tasks directory. From version 0.1.0 on the planned tasks
  # files live in the ~/.syc/syctask directory. So the calling method has the
  # responsibility to copy or move the planned tasks files after they have been
  # updated to the new planned tasks directory.
  def update_planned_tasks(dirs, excluded, new_ids)
    planned_tasks_files(dirs, excluded).each do |file|
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

  # Updates tracked_tasks file if task has been re-indexed with new ID
  def update_tracked_task(dirs, excluded)
    @tracked = get_files(dirs, excluded, /tracked_tasks/) if @tracked.nil?
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
  def task_files(dirs, excluded=[])
    get_files(dirs, excluded, /\d+\.task$/)
  end

  # Retrieves all planned task files in and below the given directory
  def planned_tasks_files(dirs, excluded=[])
    pattern = %r{\d{4}-\d{2}-\d{2}_planned_tasks}
    get_files(dirs, excluded, pattern)
  end

  # Retrieves all schedule files in and below the given directory
  def time_schedule_files(dirs, excluded=[])
    pattern = %r{\d{4}-\d{2}-\d{2}_time_schedule}
    get_files(dirs, excluded, pattern)
  end

  # Retrieves als tasks.log files in and below the given directory
  def tasks_log_files(dirs, excluded=[])
    get_files(dirs, excluded, /tasks\.log/)
  end

  # Retrieves all files that meet the pattern in and below the given directory
  def get_files(included, excluded=[], pattern)
    files = []
    Find.find(*included) do |path|
      if FileTest.directory?(path)
        if excluded.include?(path)
          Find.prune
        else
          next
        end
      else
        files << File.expand_path(path) if File.basename(path) =~ pattern  
      end
    end
    files
  end

  # Retrieve all directories that contain tasks
  def get_task_dirs(dir)
    original_dir = File.expand_path(".")
    Dir.chdir(dir)
    dirs = Dir.glob("**/*.task", File::FNM_DOTMATCH).map do |f|
      File.dirname(File.expand_path(f))
    end
    Dir.chdir(original_dir)
    dirs.uniq
  end

  # Retrieves all directories that contain tasks and the count of contained
  # tasks in and below the provided directory
  def get_task_dirs_and_count(dir)
    original_dir = File.expand_path(".")
    Dir.chdir(dir)
    dirs_and_count = Hash.new(0)
    Dir.glob("**/*.task", File::FNM_DOTMATCH).each do |f|
      dirname = File.dirname(File.expand_path(f))
      dirs_and_count[dirname] += 1
    end
    Dir.chdir(original_dir)
    dirs_and_count
  end

  # Moves the tasks.log file to the system directory if not there. Should only
  # be if upgrading from version 0.0.7 and below
  def move_task_log_file(dirs, excluded)
    if @tasks_log_files.nil?    
      @tasks_log_files = tasks_log_files(dirs, excluded) 
    end
    @tasks_log_files.each do |f|
      next if f == TASKS_LOG
      tasks_log = File.read(f)
      File.open(TASKS_LOG, 'a') {|t| t.puts tasks_log}
      FileUtils.mv(f, "#{f}_#{Time.now.strftime("%y%m%d")}")
    end
  end

  # Moves the planned tasks file to the system directory if not there. Should 
  # only be if upgrading from version 0.0.7 and below
  def move_planned_tasks_files(dirs, excluded)
    if @planned_tasks_files.nil?
      @planned_tasks_files = planned_tasks_files(dirs, excluded) 
    end
    @planned_tasks_files.each do |file|
      to_file = "#{SYC_DIR}/#{File.basename(file)}"
      next if file == to_file
      FileUtils.mv file, to_file
    end
  end

  # Moves the schedule file to the system directory if not there. Should 
  # only be if upgrading from version 0.0.7 and below
  def move_time_schedule_files(dirs, excluded)
    if @time_schedule_files.nil?
      @time_schedule_files = time_schedule_files(dirs, excluded) 
    end
    @time_schedule_files.each do |file|
      to_file = "#{SYC_DIR}/#{File.basename(file)}" 
      next if file == to_file
      FileUtils.mv file, to_file
    end 
  end

end
