Then /^the file "(.*?)" should contain JSON exactly like:$/ do |file, exact_content|
  prep_for_fs_check do
    json = IO.read(file)
    JSON.parse(json).should == JSON.parse(exact_content)
  end
end
