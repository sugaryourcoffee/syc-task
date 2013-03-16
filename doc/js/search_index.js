var search_data = {"index":{"searchIndex":["object","syctask","evaluator","meeting","schedule","task","taskplanner","taskscheduler","taskservice","times","sycutil","console","test","unit","testcase","testdefault","testevaluator","testmeeting","testschedule","testtask","testtaskplanner","testtaskscheduler","testtaskservice","testtimes","<=>()","==()","add_tasks()","assign()","char_if_pressed()","compare()","compare_dates()","compare_numbers()","create()","delete()","done()","done?()","extract_time()","find()","get_tasks()","get_times()","graph()","includes?()","matches?()","matches?()","meeting_caption()","meeting_list()","new()","new()","new()","new()","new()","new()","plan_tasks()","print_csv()","print_pretty()","prioritize_tasks()","prompt()","read()","remove_tasks()","restore()","round_up()","save()","set_busy_times()","set_meeting_titles()","set_task_assignments()","set_tasks()","set_work_time()","setup()","setup()","setup()","setup()","show()","teardown()","teardown()","teardown()","test_the_truth()","time_caption()","update()","update()","update?()","gemfile","readme","rakefile","syctask"],"longSearchIndex":["object","syctask","syctask::evaluator","syctask::meeting","syctask::schedule","syctask::task","syctask::taskplanner","syctask::taskscheduler","syctask::taskservice","syctask::times","sycutil","sycutil::console","test","test::unit","test::unit::testcase","testdefault","testevaluator","testmeeting","testschedule","testtask","testtaskplanner","testtaskscheduler","testtaskservice","testtimes","syctask::task#<=>()","syctask::task#==()","syctask::taskplanner#add_tasks()","syctask::schedule#assign()","sycutil::console#char_if_pressed()","syctask::evaluator#compare()","syctask::evaluator#compare_dates()","syctask::evaluator#compare_numbers()","syctask::taskservice#create()","syctask::taskservice#delete()","syctask::task#done()","syctask::task#done?()","object#extract_time()","syctask::taskservice#find()","syctask::taskplanner#get_tasks()","syctask::schedule#get_times()","syctask::schedule#graph()","syctask::evaluator#includes?()","syctask::evaluator#matches?()","syctask::task#matches?()","syctask::schedule#meeting_caption()","syctask::schedule#meeting_list()","syctask::meeting::new()","syctask::schedule::new()","syctask::task::new()","syctask::taskplanner::new()","syctask::taskscheduler::new()","syctask::times::new()","syctask::taskplanner#plan_tasks()","syctask::task#print_csv()","syctask::task#print_pretty()","syctask::taskplanner#prioritize_tasks()","sycutil::console#prompt()","syctask::taskservice#read()","syctask::taskplanner#remove_tasks()","syctask::taskscheduler#restore()","syctask::times#round_up()","syctask::taskservice#save()","syctask::taskscheduler#set_busy_times()","syctask::taskscheduler#set_meeting_titles()","syctask::taskscheduler#set_task_assignments()","syctask::taskscheduler#set_tasks()","syctask::taskscheduler#set_work_time()","testevaluator#setup()","testtaskplanner#setup()","testtaskscheduler#setup()","testtaskservice#setup()","syctask::taskscheduler#show()","testtaskplanner#teardown()","testtaskscheduler#teardown()","testtaskservice#teardown()","testdefault#test_the_truth()","syctask::schedule#time_caption()","syctask::task#update()","syctask::taskservice#update()","syctask::task#update?()","","","",""],"info":[["Object","","Object.html","",""],["Syctask","","Syctask.html","","<p>Syctask provides functions for managing tasks in a task list\n<p>Syctask provides functions for managing tasks …\n"],["Syctask::Evaluator","","Syctask/Evaluator.html","","<p>Evaluator provides different evaluatons for comparing numbers, dates and\nstrings. Also provides methods …\n"],["Syctask::Meeting","","Syctask/Meeting.html","","<p>Meeting represents a meeting containing the begin and end time, a title and\nan agenda consisting of tasks …\n"],["Syctask::Schedule","","Syctask/Schedule.html","","<p>Schedule represents a working day with a start and end time, meeting times\nand titles and tasks. Tasks …\n"],["Syctask::Task","","Syctask/Task.html","","<p>A Task is the basic element of the task list and holds all information\nabout a task.\n"],["Syctask::TaskPlanner","","Syctask/TaskPlanner.html","","<p>A TaskPlanner prompts the user to select tasks for today. These tasks can\nbe prioritized to determine …\n"],["Syctask::TaskScheduler","","Syctask/TaskScheduler.html","","<p>The TaskScheduler creates a graphical representation of a working schedule\nwith busy times visualized. …\n"],["Syctask::TaskService","","Syctask/TaskService.html","","<p>Provides services to operate tasks as create, read, find, update and save\nTask objects\n"],["Syctask::Times","","Syctask/Times.html","","<p>Times class represents a time consisting of hour and minutes\n"],["Sycutil","","Sycutil.html","","<p>Module Sycutil contains functions related to the Console that is helpers\nfor user input\n"],["Sycutil::Console","","Sycutil/Console.html","","<p>Console provides functions for user input\n"],["Test","","Test.html","",""],["Test::Unit","","Test/Unit.html","",""],["Test::Unit::TestCase","","Test/Unit/TestCase.html","","<p>Add test libraries you want to use here, e.g. mocha\n"],["TestDefault","","TestDefault.html","","<p>Dummy test\n"],["TestEvaluator","","TestEvaluator.html","","<p>Tests for the Evaluator class\n"],["TestMeeting","","TestMeeting.html","","<p>Tests for the Meeting class\n"],["TestSchedule","","TestSchedule.html","","<p>Tests for the Schedule class\n"],["TestTask","","TestTask.html","","<p>Tests for the Task\n"],["TestTaskPlanner","","TestTaskPlanner.html","","<p>Tests for the TaskPlanner class\n"],["TestTaskScheduler","","TestTaskScheduler.html","","<p>Tests for the TaskScheduler class\n"],["TestTaskService","","TestTaskService.html","","<p>Tests for the TaskService\n"],["TestTimes","","TestTimes.html","","<p>Tests for the Times class\n"],["<=>","Syctask::Task","Syctask/Task.html#method-i-3C-3D-3E","(other)","<p>Compares this Task to the other task and compares them regarding the ID \nand the dir. If ID is equal …\n"],["==","Syctask::Task","Syctask/Task.html#method-i-3D-3D","(other)","<p>Compares this task with another task regarding id and dir. If both are \nequal true is returned otherwise …\n"],["add_tasks","Syctask::TaskPlanner","Syctask/TaskPlanner.html#method-i-add_tasks","(tasks)","<p>Add the tasks to the planned tasks\n"],["assign","Syctask::Schedule","Syctask/Schedule.html#method-i-assign","(assignments)","<p>Sets the assignments containing tasks that are assigned to meetings.\nReturns true if succeeds\n"],["char_if_pressed","Sycutil::Console","Sycutil/Console.html#method-i-char_if_pressed","()","<p>Listens for key presses and returns the pressed key without pressing return\n"],["compare","Syctask::Evaluator","Syctask/Evaluator.html#method-i-compare","(value, operands)","<p>Compares two values regarding &lt;|=|&gt;. Returns true if the comparisson\nsucceeds otherwise false. …\n"],["compare_dates","Syctask::Evaluator","Syctask/Evaluator.html#method-i-compare_dates","(value, pattern)","<p>Compares two dates regarding &lt;|=|&gt;. Returns true if the comparisson\nsucceeds otherwise false.  …\n"],["compare_numbers","Syctask::Evaluator","Syctask/Evaluator.html#method-i-compare_numbers","(value, pattern)","<p>Compares two numbers regarding &lt;|=|&gt;. Returns true if the comparisson\nsucceeds otherwise false. …\n"],["create","Syctask::TaskService","Syctask/TaskService.html#method-i-create","(dir, options, title)","<p>Creates a new task in the specified directory, with the specified options\nand the specified title. If …\n"],["delete","Syctask::TaskService","Syctask/TaskService.html#method-i-delete","(dir, filter)","<p>Deletes tasks in the specified directory that match the provided filter. If\nno filter is provide no task …\n"],["done","Syctask::Task","Syctask/Task.html#method-i-done","(note=\"\")","<p>Marks the task as done. When done than the done date is set. Optionally a\nnote can be provided.\n"],["done?","Syctask::Task","Syctask/Task.html#method-i-done-3F","()","<p>Checks if this task is done. Returns true if done otherwise false\n"],["extract_time","Object","Object.html#method-i-extract_time","(time_string)","<p>Extracts the time out of a time string. Accepts ‘today’, ‘tomorrow’ or a\ndate in the form ‘YYYY-MM-DD’. …\n"],["find","Syctask::TaskService","Syctask/TaskService.html#method-i-find","(dir, filter={}, all=true)","<p>Finds all tasks that match the given filter. The filter can be provided for\n:id, :title, :description, …\n"],["get_tasks","Syctask::TaskPlanner","Syctask/TaskPlanner.html#method-i-get_tasks","(date=Time.now.strftime(\"%Y-%m-%d\"), filter={})","<p>Get planned tasks of the specified date. Retrieve only tasks that match the\nspecified filter (filter …\n"],["get_times","Syctask::Schedule","Syctask/Schedule.html#method-i-get_times","()","<p>Retrieves the work and busy times transformed to the time line scale\n"],["graph","Syctask::Schedule","Syctask/Schedule.html#method-i-graph","()","<p>graph first creates creates the time line. Then the busy times are added.\nAfter that the tasks are added …\n"],["includes?","Syctask::Evaluator","Syctask/Evaluator.html#method-i-includes-3F","(value, pattern)","<p>Evaluates whether value is part of the provided csv pattern. Returns true\nif it evaluates to true otherwise …\n"],["matches?","Syctask::Evaluator","Syctask/Evaluator.html#method-i-matches-3F","(value, regex)","<p>Evaluates if value matches the provided regex. Returns true if a match is\nfound. If value or regex is …\n"],["matches?","Syctask::Task","Syctask/Task.html#method-i-matches-3F","(filter = {})","<p>Compares the provided elements in the filter with the correspondent\nelements in the task. When all comparissons …\n"],["meeting_caption","Syctask::Schedule","Syctask/Schedule.html#method-i-meeting_caption","()","<p>Creates a meeting caption and returns it for printing\n"],["meeting_list","Syctask::Schedule","Syctask/Schedule.html#method-i-meeting_list","()","<p>Creates a meeting list for printing. Returns the meeting list\n"],["new","Syctask::Meeting","Syctask/Meeting.html#method-c-new","(time, title=\"\", tasks=[])","<p>Sets the busy time for the schedule. The busy times have to be provided as\nhh:mm-hh:mm. Optionally a …\n"],["new","Syctask::Schedule","Syctask/Schedule.html#method-c-new","(work_time, busy_time=[], titles=[], tasks=[])","<p>Creates a new Schedule and initializes work time, busy times, titles and\ntasks. Work time is mandatory, …\n"],["new","Syctask::Task","Syctask/Task.html#method-c-new","(options={}, title, id)","<p>Creates a new task. If the options contain a note than the current date and\ntime is added.\n"],["new","Syctask::TaskPlanner","Syctask/TaskPlanner.html#method-c-new","()","<p>Creates a new TaskPlanner\n"],["new","Syctask::TaskScheduler","Syctask/TaskScheduler.html#method-c-new","()","<p>Creates a new TaskScheduler.\n"],["new","Syctask::Times","Syctask/Times.html#method-c-new","(time)","<p>Creates a new Times object. time has to be provided as an array with the\ncontent as [“hour”,“minute”] …\n"],["plan_tasks","Syctask::TaskPlanner","Syctask/TaskPlanner.html#method-i-plan_tasks","(tasks, date=Time.now.strftime(\"%Y-%m-%d\"))","<p>List each task and prompt the user whether to add the task to the planned\ntasks. The user doesn’t specify …\n"],["print_csv","Syctask::Task","Syctask/Task.html#method-i-print_csv","()","<p>Prints the task as a CSV\n"],["print_pretty","Syctask::Task","Syctask/Task.html#method-i-print_pretty","(long=false)","<p>Prints the task in a formatted way eather all values when long is true or\nonly id, title, prio, follow-up …\n"],["prioritize_tasks","Syctask::TaskPlanner","Syctask/TaskPlanner.html#method-i-prioritize_tasks","(date=Time.now.strftime(\"%Y-%m-%d\"), filter={})","<p>Prioritize tasks by pair wise comparisson. Each task is compared to the\nother tasks and the user can …\n"],["prompt","Sycutil::Console","Sycutil/Console.html#method-i-prompt","(choice_line)","<p>Prompts the user for input.\n<p>choice_line is the prompt string. If the prompt string contains a (x)\nsequence …\n"],["read","Syctask::TaskService","Syctask/TaskService.html#method-i-read","(dir, id)","<p>Reads the task with given ID id located in given directory dir. If task\ndoes not exist nil is returned …\n"],["remove_tasks","Syctask::TaskPlanner","Syctask/TaskPlanner.html#method-i-remove_tasks","(date=Time.now.strftime(\"%Y-%m-%d\"), filter={})","<p>Remove planned tasks from the task plan based on the provided filter\n(filter options see Task#matches? …\n"],["restore","Syctask::TaskScheduler","Syctask/TaskScheduler.html#method-i-restore","(value)","<p>Restores the value of a previous invokation. Posible values are :work_time,\n:busy_time, :meetings and …\n"],["round_up","Syctask::Times","Syctask/Times.html#method-i-round_up","()","<p>Rounds the time to the next hour if minutes is greater than 0\n"],["save","Syctask::TaskService","Syctask/TaskService.html#method-i-save","(dir, task)","<p>Saves the task to the task directory. If dir is nil the default dir\n~/.tasks will be set.\n"],["set_busy_times","Syctask::TaskScheduler","Syctask/TaskScheduler.html#method-i-set_busy_times","(busy_time)","<p>Set the busy times. Raises an exception if one begin time is after start\ntime Invokation: set_busy_times([ …\n"],["set_meeting_titles","Syctask::TaskScheduler","Syctask/TaskScheduler.html#method-i-set_meeting_titles","(titles)","<p>Sets the titles of the meetings (busy times) Invokation:\nset_meeting_titles(“title1,title2,title3”) …\n"],["set_task_assignments","Syctask::TaskScheduler","Syctask/TaskScheduler.html#method-i-set_task_assignments","(assignments)","<p>Add scheduled tasks to busy times Invokation:\nset_task_assignments([,[“B”,“2,5,6,7”]]) …\n"],["set_tasks","Syctask::TaskScheduler","Syctask/TaskScheduler.html#method-i-set_tasks","(tasks)","<p>Sets the tasks for scheduling\n"],["set_work_time","Syctask::TaskScheduler","Syctask/TaskScheduler.html#method-i-set_work_time","(work_time)","<p>Set the work time. Raises an exception if begin time is after start time\nInvokation: set_work_time() …\n"],["setup","TestEvaluator","TestEvaluator.html#method-i-setup","()","<p>Creates the evaluator object before each shoulda\n"],["setup","TestTaskPlanner","TestTaskPlanner.html#method-i-setup","()","<p>Sets up the test and initializes variables used in the tests\n"],["setup","TestTaskScheduler","TestTaskScheduler.html#method-i-setup","()","<p>Sets up the test case and initializes the directory for the test tasks to\nlive\n"],["setup","TestTaskService","TestTaskService.html#method-i-setup","()","<p>Creates a TaskService object used in each shoulda\n"],["show","Syctask::TaskScheduler","Syctask/TaskScheduler.html#method-i-show","()","<p>Prints the meeting list, timeline and task list\n"],["teardown","TestTaskPlanner","TestTaskPlanner.html#method-i-teardown","()","<p>Removes files and directories created during the tests\n"],["teardown","TestTaskScheduler","TestTaskScheduler.html#method-i-teardown","()","<p>Removes after each test the test task directory\n"],["teardown","TestTaskService","TestTaskService.html#method-i-teardown","()","<p>Removes files and directories created by the tests\n"],["test_the_truth","TestDefault","TestDefault.html#method-i-test_the_truth","()","<p>Always passes the test\n"],["time_caption","Syctask::Schedule","Syctask/Schedule.html#method-i-time_caption","()","<p>Creates the time caption for the time line\n"],["update","Syctask::Task","Syctask/Task.html#method-i-update","(options)","<p>Updates the task with new values. Except for note and tags which are\nsupplemented with the new values …\n"],["update","Syctask::TaskService","Syctask/TaskService.html#method-i-update","(dir, id, options)","<p>Updates the task with the given id in the given directory dir with the\nprovided options.  Options are …\n"],["update?","Syctask::Task","Syctask/Task.html#method-i-update-3F","()","<p>Checks whether this task has been updated. Returns true if updated\notherwise false\n"],["Gemfile","","Gemfile.html","","<p>source :rubygems gemspec\n"],["README","","README_rdoc.html","","<p>Simple task organizer\n<p>syctask can be used to create, plan, prioritize and schedule tasks.\n<p>Install\n"],["Rakefile","","Rakefile.html","","<p>require ‘rake/clean’ require ‘rubygems’ require ‘rubygems/package_task’\nrequire ‘rdoc/task’ require ‘cucumber’ …\n"],["syctask","","syctask_rdoc.html","","<p>syctask\n<p>Generate this with\n\n<pre>syctask rdoc</pre>\n"]]}}