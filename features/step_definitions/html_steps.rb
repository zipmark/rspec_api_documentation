When /^I open the index$/ do
  visit "/index.html"
end

When /^I navigate to "([^"]*)"$/ do |example|
  click_link example
end

Then /^I should see the following resources:$/ do |table|
  expect(all("h2").map(&:text)).to eq(table.raw.flatten)
end

Then /^I should see the following parameters:$/ do |table|
  names = all(".parameters .name").map(&:text)
  descriptions = all(".parameters .description").map(&:text)

  expect(names.zip(descriptions)).to eq(table.rows)
end

Then(/^I should see the following response fields:$/) do |table|
  names = all(".response-fields .name").map(&:text)
  descriptions = all(".response-fields .description").map(&:text)

  expect(names.zip(descriptions)).to eq(table.rows)
end

Then /^I should see the following (request|response) headers:$/ do |part, table|
  actual_headers = page.find("pre.#{part}.headers").text
  expected_headers = table.raw.map { |row| row.join(": ") }

  expected_headers.each do |row|
    expect(actual_headers).to include(row.strip)
  end
end

Then /^I should not see the following (request|response) headers:$/ do |part, table|
  actual_headers = page.find("pre.#{part}.headers").text
  expected_headers = table.raw.map { |row| row.join(": ") }

  expected_headers.each do |row|
    expect(actual_headers).to_not include(row.strip)
  end
end

Then /^I should see the route is "([^"]*)"$/ do |route|
  expect(page).to have_css(".request.route", :text => route)
end

Then /^I should see the following query parameters:$/ do |table|
  text = page.find("pre.request.query_parameters").text
  actual = text.split("\n")
  expected = table.raw.map { |row| row.join(": ") }

  expect(actual).to match(expected)
end

Then /^I should see the response status is "([^"]*)"$/ do |status|
  expect(page).to have_css(".response.status", :text => status)
end

Then /^I should see the following request body:$/ do |request_body|
  expect(page).to have_css("pre.request.body", :text => request_body)
end

Then /^I should see the following response body:$/ do |response_body|
  expect(page).to have_css("pre.response.body", :text => response_body)
end

Then /^I should see the api name "(.*?)"$/ do |name|
  title = find("title").text
  header = find("h1").text

  expect(title).to eq(name)
  expect(header).to eq(name)
end
