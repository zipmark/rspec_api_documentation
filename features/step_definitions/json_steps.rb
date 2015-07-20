Then /^the file "(.*?)" should contain JSON exactly like:$/ do |file, exact_content|
  in_current_directory do
    json = IO.read(file)
    expect(JSON.parse(json)).to eq(JSON.parse(exact_content))
  end
end
