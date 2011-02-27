Then /^the output contains the current version$/ do
  Then %{the output should match /^#{One9::VERSION}/}
end

Given /^I have no report$/ do
  FileUtils.rm_f One9::Report.marshal_file
end
