When /^I get help for "([^"]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} help`)
end

Given /^no task is available in "(.*?)"$/ do |directory|
  FileUtils.rm Dir.glob("#{directory}/*") if File.exists? directory
end

Then /^a task should be in "(.*?)"$/ do |directory|
  Dir[directory].size.should == 1
end

And /^the task should contain prio "(.*?)" and tags "(.*?)"$/ do |prio, tags|
  pending("read the task and check prio and tags are equal to values")
end

Then /^the task should contain prio "(.*?)" a tag "(.*?)" a follow\-up date "(.*?)" a due date "(.*?)" a description "(.*?)" and a note "(.*?)"$/ do |prio, tag, follow_up_date, due_date, description, note|
  pending("read the task and check the variables to be same")
end
