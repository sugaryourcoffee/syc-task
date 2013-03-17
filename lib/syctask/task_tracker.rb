require_relative 'environment.rb'
require_relative 'task_service.rb'

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
    TRACKED_TASKS_FILE = Syctask::WORK_DIR + '/' + 'tracked_tasks'

    # Creates a new TaskTracker
    def initialize
      @service = Syctask::TaskService.new
      load_tracks
    end

    # When a task is started it is saved to the started_tasks file with the
    # start time. When it is stopped (see #stop) it is removed from the
    # started_tasks file and the processing time is added to the lead_time
    # field of the task. A started task will print every 15 minutes a message
    # to the console. Returns true if the task is started. To try to start an
    # already running task will return false indicating that the task has
    # already been started. True is returned if the task has been started.
    def start(task)
      index = @tasks.find_index(task)
      return false if not index.nil? and index == 0

      if index.nil?
        track = Track.new(task)
      else
        stop
        track = @tracks.delete_at(index)
      end

      track.start
      @tracks.insert(0,track)

      @tasks.insert(0,task)

      save_tracks

      true
      
    end

    # When a task is stopped it is removed from the started_tasks file and the
    # processing time is added to the lead_time field of the task. #stop
    # returns the currently started but idling tasks in the started_tasks file.
    def stop
      task = @tasks[0]
      if task.lead_time
        task.lead_time += @tracks[0].stop
      else
        task.lead_time = @tracks[0].stop
      end

      @service.save(task.dir, task)
      @tracks.delete_at(0)
      @tasks.delete_at(0)
      @tasks
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
        @tracks.each { |track| @tasks << @service.read(track.dir, track.id) }
      end
    end

  end

  # A Track holds a task and stops the time the task is processed. The Track
  # will print every 5 minutes the elapsed time and the time left to the
  # specified Task#duration. 
  class Track

    # Directory where the tracked task is saved
    attr_reader :dir
    # ID of the tracked task
    attr_reader :id
    # Title of the tracked task

    # Creates a new Track for the provided task
    def initialize(task)
      @dir = task.dir
      @id = task.id
      @title = task.title
    end

    # Starts the tracking and a timer that will print to STDOUT every 5 minutes
    # the elapsed time and the time left until Task#duration
    def start
      @started ||= Time.now
      # start a timer that prints title and elapsed time every 5 minutes
    end
    
    # Stops the task tracking and returns the lead time of the task
    def stop
      @stopped ||= Time.now
      @stopped - @started
    end

  end

end
