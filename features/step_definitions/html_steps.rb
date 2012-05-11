When /^I open the index$/ do
  visit "/index.html"
end

When /^I navigate to "([^"]*)"$/ do |example|
  click_link example
end

Then /^I should see the following resources:$/ do |table|
  all("h2").map(&:text).should == table.raw.flatten
end

Then /^I should see the following parameters:$/ do |table|
  names = all(".parameters .name").map(&:text)
  descriptions = all(".parameters .description").map(&:text)
  names.zip(descriptions).should == table.rows
end

Then /^I should see the following (request|response) headers:$/ do |part, table|
  text = page.find("pre.#{part}.headers").text
  actual_headers = text.split("\n")
  expected_headers = table.raw.map { |row| row.join(": ") }
  actual_headers.should =~ expected_headers
end

Then /^I should see the route is "([^"]*)"$/ do |route|
  page.should have_css(".request.route", :text => route)
end

Then /^I should see the following query parameters:$/ do |table|
  text = page.find("pre.request.query_parameters").text
  actual = text.split("\n")
  expected = table.raw.map { |row| row.join(": ") }
  actual.should =~ expected
end

Then /^I should see the response status is "([^"]*)"$/ do |status|
  page.should have_css(".response.status", :text => status)
end

Then /^I should see the following request body:$/ do |request_body|
  page.should have_css("div.request.body", :text => request_body)
end

Then /^I should see the following response body:$/ do |response_body|
  page.should have_css("div.response.body textarea", :text => response_body)
end

Then /^I see the page$/ do
  puts page.body
end