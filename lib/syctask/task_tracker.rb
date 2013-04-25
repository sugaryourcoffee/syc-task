require 'yaml'
require 'fileutils'
require_relative 'environment.rb'
require_relative 'task_service.rb'
#require_relative '../sycutil/console_timer.rb'

module Syctask

  # TaskTracker provides methods to start a task and stop a task. The objective
  # is to track the processing time for a task. The processing time can be
  # analyzed with the TaskStatistics class. When a task is started it is saved
  # to the started_tasks file. If another task is started the currently active
  # task is stopped and the newly started file is put on top of the
  # started_tasks file. When stopping a task the currently started tasks will
  # be returned and one of the idling tasks can be restarted. When a task is
  # stopped the processing time is added to the task's lead_time field.
  class TaskTracker
    
    # File name of the file where the tracked files are saved to
    TRACKED_TASKS_FILE = Syctask::TRACKED_TASK #Syctask::WORK_DIR + '/' + 'tracked_tasks'
    # File name of the task log file
    TASK_LOG_FILE = Syctask::TASKS_LOG #Syctask::WORK_DIR + '/' + 'tasks.log'

    # Creates a new TaskTracker
    def initialize
      @service = Syctask::TaskService.new
      load_tracks
    end

    # When a task is started it is saved with the start time. If a task is
    # already tracked it is stopped (see #stop).  A started task will print 
    # every second a message to the console if the show parameter is true.
    # start returns
    # * [false, nil ] if the task is already tracked 
    # * [true,  nil ] if the task is started and no task was running. 
    # * [true,  task] if task is started and the previously running task stopped
    def start(task, show=true)
      raise ArgumentError, "Error: Task without directory.\n"+
                           "--> Update task with syctask -t <dir> update "+
                           "#{task.id}" unless task.dir
      index = @tasks.find_index(task)
      return [false, nil] if not index.nil? and index == 0

      stopped_task = stop
      track = Track.new(task)

      track.start(show)
      log_task(:start, track)

      @tracks.insert(0,track)

      @tasks.insert(0,task)

      save_tracks

      [true, stopped_task]
      
    end

    # When a task is stopped it is removed from the started_tasks file and the
    # processing time is added to the lead_time field of the task. #stop
    # returns the stopped task in an Array or an empty Array if no task is
    # running an hence no task can be stopped.
    def stop
      return nil unless @tasks[0]

      task = @tasks[0]
      task.update_lead_time(@tracks[0].stop)
      @service.save(task.dir, task)

      log_task(:stop, @tracks[0])

      @tracks.delete_at(0)
      @tasks.delete_at(0)
      save_tracks

      task
    end

    # Retrieves the currently tracked task returns nil if no task is tracked
    def tracked_task
      @tasks[0]
    end

    private

    # Saves the tracks to the tracked tasks file
    def save_tracks
      FileUtils.mkdir_p WORK_DIR unless File.exists? WORK_DIR
      File.open(TRACKED_TASKS_FILE, 'w') do |file|
        YAML.dump(@tracks, file) 
      end
    end

    # Loads the tracks from the tracked tasks file to @tasks and
    # @tracks. If no tracked tasks exist @tracks and @tasks will be
    # empty
    def load_tracks
      unless File.exists? TRACKED_TASKS_FILE
        @tracks = []
        @tasks = []
      else
        @tracks ||= YAML.load_file(TRACKED_TASKS_FILE)
        @tasks = []
        if @tracks
          @tracks.each { |track| @tasks << @service.read(track.dir, track.id) }
        end
      end
    end

    # Logs the start and stop of a task.
    def log_task(type, track)
      FileUtils.mkdir_r Syctask::WORK_DIR unless File.exists? Syctask::WORK_DIR
      File.open(TASK_LOG_FILE, 'a') do |file|
        log_entry =  "#{type.to_s};"
        log_entry += "#{track.id};#{track.dir};"
        log_entry += "#{track.title};"
        log_entry += "#{track.started};"
        log_entry += "#{track.stopped}" 
        file.puts log_entry
      end
    end

  end

  # A Track holds a task and stops the time the task is processed. The Track
  # will print every second the elapsed time and the time left to the
  # specified Task#duration. 
  class Track

    # Directory where the tracked task is saved
    attr_reader :dir
    # ID of the tracked task
    attr_reader :id
    # Title of the tracked task
    attr_reader :title
    # When tracking started
    attr_reader :started
    # When tracking stopped
    attr_reader :stopped

    # Creates a new Track for the provided task
    def initialize(task)
      @dir = task.dir
      @id = task.id
      @title = task.title
      @duration = task.remaining.to_i
      @semaphore = "#{Syctask::SYC_DIR}/#{@id}.track"
    end

    # Starts the tracking and a timer that will print to STDOUT every second
    # the elapsed time and the time left until Task#duration
    def start(show)
      @started ||= Time.now
      # start a timer that prints id and elapsed time 
      FileUtils.touch @semaphore
      system "console_timer #{@duration} #{@id} #{@semaphore} &" if show
    end
    
    # Stops the task tracking and returns the lead time of the task
    def stop
      FileUtils.rm @semaphore if @semaphore and File.exists? @semaphore
      @stopped ||= Time.now
      @stopped - @started
    end

  end

end
