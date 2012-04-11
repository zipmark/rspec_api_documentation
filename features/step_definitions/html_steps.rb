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

Then /^I should see the following (request|response) headers:$/ do |part, headers|
  page.should have_css("pre.#{part}.headers", :text => headers)
end

Then /^I should see the route is "([^"]*)"$/ do |route|
  page.should have_css(".request.route", :text => route)
end

Then /^I should see the following query parameters:$/ do |query_parameters|
  page.should have_css("pre.request.query_parameters"), :text => query_parameters
end

Then /^I should see the response status is "([^"]*)"$/ do |status|
  page.should have_css(".response.status", :text => status)
end

Then /^I should see the following response body:$/ do |response_body|
  page.should have_css("div.response.body", :text => response_body)
end
