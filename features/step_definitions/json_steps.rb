Then /^the file "(.*?)" should contain JSON exactly like:$/ do |file, exact_content|
  prep_for_fs_check do
    json = IO.read(file)
    expect(JSON.parse(json)).to eq(JSON.parse(exact_content))
  end
end
