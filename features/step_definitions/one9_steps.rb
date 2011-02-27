Then /^the output contains the current version$/ do
  Then %{the output should match /^#{One9::VERSION}/}
end

Given /^I have no report$/ do
  FileUtils.rm_f One9::Report.marshal_file
end

Given /^I have a report$/ do
  FileUtils.touch One9::Report.marshal_file
end

Given /^I have the editor "([^"]*)"$/ do |editor|
  ENV['EDITOR'] = editor
end

Given /^I run "([^"]*)" which hangs$/ do |cmd|
  @aruba_timeout_seconds = 0.1
  begin
    Then %{I run "#{cmd}"}
  rescue ChildProcess::TimeoutError
  end
  @aruba_timeout_seconds = nil
end

Then /^the output should not contain multiple reports$/ do
  all_output.should_not =~ /One9 Report.*One9 Report/m
end
