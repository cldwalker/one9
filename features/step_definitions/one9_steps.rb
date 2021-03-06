After do
  FileUtils.rm_rf One9.dir
end

Given /^I have no rc file$/ do
  FileUtils.rm_f One9.rc
end

Given /^I have a rc file$/ do
  FileUtils.mkdir_p One9.dir
  File.open(One9.rc, 'w') {|f| f.write 'change "Module#stub", "stuuub"' }
end

Given /^I have no report$/ do
  FileUtils.rm_f One9::Report.marshal_file
end

Given /^I have a report$/ do
  FileUtils.mkdir_p One9.dir
  stacks = {
    "Module#instance_methods" => [['./lib/blah.rb:11']],
    "Module#private_instance_methods" => [['./lib/blah.rb:21']],
    "Hash#to_s" => [['./lib/blah.rb:31']],
    "Hash#select" => [['./lib/blah.rb:41']],
    "Module#public_methods" => [['./test/blah.rb:51']]
  }
  File.open(One9::Report.marshal_file, 'wb') {|f| f.write Marshal.dump([{}, stacks]) }
end

Given /^I have an invalid report$/ do
  FileUtils.mkdir_p One9.dir
  File.open(One9::Report.marshal_file, 'w') {|f| f.write '' }
end

Given /^I have a report with no data$/ do
  FileUtils.mkdir_p One9.dir
  File.open(One9::Report.marshal_file, 'wb') {|f| f.write Marshal.dump([{}, {}]) }
end

Given "I have a Rails report" do
  FileUtils.mkdir_p One9.dir
  stacks = {
    "Module#instance_methods" => [['./app/models/blah.rb:11']],
    "Module#constants" => [['./config/initializers/blah.rb:21']],
    "Kernel.global_variables" => [['./vendor/gems/blah.rb:31']],
    "Hash#to_s" => [['./lib/blah.rb:41']],
  }
  File.open(One9::Report.marshal_file, 'wb') {|f| f.write Marshal.dump([{}, stacks]) }
end

Given "I'm in a Rails environment" do
  Given %{an empty file named "config/environment.rb"}
end

Given /^I am unable to save my test$/ do
  FileUtils.rm_rf One9.dir
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

Then /^the output contains all default methods$/ do
  One9::Rc.meths.clear
  meths = One9.load_methods.delete_if {|e| e.name[/pretty_print/] }
  meths.map(&:name).each do|meth|
    Then %{the output should contain "#{meth}"}
  end
end

Then /^the output contains the current version$/ do
  Then %{the output should match /^#{One9::VERSION}/}
end
