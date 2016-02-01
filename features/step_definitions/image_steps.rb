Given /^I move the sample image into the workspace$/ do
  FileUtils.cp("features/fixtures/file.png", expand_path("."))
end

Then /^the generated documentation should be encoded correctly$/ do
  file = File.read(File.join(expand_path("."), "doc", "api", "foobars", "uploading_a_file.html"))
  expect(file).to match(/file\.png/)
end
