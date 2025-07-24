Then /^the file "(.*?)" should contain JSON exactly like:$/ do |file, exact_content|
  actual = JSON.dump(JSON.parse(read(file).join))
  expected = JSON.dump(JSON.parse(exact_content))
  expect(actual).to eq(expected)
end
