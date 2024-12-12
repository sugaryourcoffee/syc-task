When /^I get help for "([^"]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} help`)
end

Given /^no task is available in "(.*?)"$/ do |directory|
  FileUtils.rm Dir.glob("#{directory}/*") if File.exist? directory
end

Given(/^no task is available in the default task directory$/) do
  step %(no task is available in "#{ENV['HOME']}/.tasks")
end

Then(/^the directory "([^"]*)" should contain "([^"]*)" tasks$/) do |dir, size|
  expect(Dir[dir].size).to eq size.to_i
end

Then /^a task should be in "(.*?)"$/ do |directory|
  step %(the directory "#{directory}" should contain "1" task)
end

Then(/^a task should be in the default task directory$/) do
  step %(the directory "#{ENV['HOME']}/.tasks" should contain "1" tasks)  
end

# And /^the task should contain prio "(.*?)" and tags "(.*?)"$/ do |prio, tags|
#   pending("read the task and check prio and tags are equal to values")
# end

# Then /^the task should contain prio "(.*?)" a tag "(.*?)" a follow\-up date "(.*?)" a due date "(.*?)" a description "(.*?)" and a note "(.*?)"$/ do |prio, tag, follow_up_date, due_date, description, note|
#   pending("read the task and check the variables to be same")
# end

Given(/^the task directory "([^"]*)" doesn't exist$/) do |task_dir|
  FileUtils.rm_r task_dir if File.exist? task_dir
end

Given(/^I have a file "([^"]*)" file with "([^"]*)" tasks and all fields set$/) do |mom, tasks|
  mom_tasks = <<-HEREDOC
    This is some regular text that should not be scanned.
    @Tasks;
    title;description;prio;due_date;follow_up;note;tags
    task1;description1;3;2016-09-10;2016-09-09;note1;a,b,c
    task2;description2;2;2016-09-11;2016-09-10;note2;d,e,f
    task3;description3;1;2016-09-12;2016-09-11;note3;g,h,i

    And this line should not be scanned.
  HEREDOC
  File.write(mom, mom_tasks)
end
  
Then(/^the files "([^"]*)" should exist$/) do |files|
  STDERR.puts "/tmp/ - #{Dir['/tmp/mom*']}"
  files.split(',').reduce(true) do |result, file| 
    (File.exist? file.strip) && result
  end
end

Given(/^I have a file "([^"]*)" with @tasks and @task annotations with different fields$/) do |file|
  content = <<-HEREDOC
  This is a text that should be ignored

  Now several tasks are listed
  @tasks;
  title;description;prio
  Title1;Description1;1
  Title2;Description2;2

  Nothing to scan. But next only one task to scan
  @task;
  title;prio
  Title3;3
  Title4;4

  And nothing to scan
  HEREDOC

  File.write(file, content)
end

Given(/^I have a file "([^"]*)" with @tasks annotation$/) do |file|
  content = <<-HEREDOC
  This is a text that should be ignored

  Now several tasks are listed
  @tasks;
  title;description;prio
  Title1;Description1;1
  Title2;Description2;2

  Nothing to scan. But next more tasks to scan
  Title3;Description3;3
  Title4;Description4;4

  And nothing to scan
  HEREDOC

  File.write(file, content)

end
