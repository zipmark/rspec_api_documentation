RSpec::Matchers.define :contain_ignoring_whitespace do |expected|
  match do |actual|
    insignificant_whitespace = /(^\s*)|(\s*$)/
    actual.gsub(insignificant_whitespace, "").should =~ regexp(expected.gsub(insignificant_whitespace, ""))
  end
end

Then /^the file "([^"]*)" should contain HTML:$/ do |file, partial_html|
  prep_for_fs_check do
    content = IO.read(file)
    content.should contain_ignoring_whitespace(partial_html)
  end
end
