Then /the outputted docs should( not)? filter out headers$/ do |condition|
  visit "/foobars/getting_foo.html"

  within("pre.curl") do
    if condition
      page.should have_content("Host")
      page.should have_content("Cookie")
    else
      page.should_not have_content("Host")
      page.should_not have_content("Cookie")
    end
  end
end
