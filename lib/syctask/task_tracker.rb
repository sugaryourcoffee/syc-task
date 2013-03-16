module Syctask

  # TaskTracker provides methods to start a task and stop a task. The objective
  # is to track the processing time for a task. The processing time can be
  # analyzed with the TaskStatistics class. When a task is started it is saved
  # to the started_tasks file. If another task is started the currently active
  # task is stopped and the newly started file is put on top of the
  # started_tasks file. When stopping a task the currently started tasks will
  # be returned and one of the idling tasks can be restarted. When a task is
  # stopped the processing time is added to the task's processing_time field.
  class TaskTracker
    
    # When a task is started it is saved to the started_tasks file with the
    # start time. When it is stopped (see #stop) it is removed from the
    # started_tasks file and the processing time is added to the processing_time
    # field of the task.
    def start(task)
    end

    # When a task is stopped it is removed from the started_tasks file and the
    # processing time is added to the processing_time field of the task. #stop
    # returns the currently started but idling tasks in the started_tasks file.
    def stop(task)
    end

  end

end
