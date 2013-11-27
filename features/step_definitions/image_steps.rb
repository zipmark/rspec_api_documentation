Given /^I move the sample image into the workspace$/ do
  FileUtils.cp("features/fixtures/file.png", current_dir)
end

Then /^the generated documentation should be encoded correctly$/ do
  file = File.read(File.join(current_dir, "doc", "api", "foobars", "uploading_a_file.html"))
  file.should =~ /file\.png/
end
