Then /^the output contains the current version$/ do
  Then %{the output should match /^#{One9::VERSION}/}
end
