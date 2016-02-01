Then /^the file "(.*?)" should contain JSON exactly like:$/ do |file, exact_content|
  expect(JSON.parse(read(file).join)).to eq(JSON.parse(exact_content))
end
