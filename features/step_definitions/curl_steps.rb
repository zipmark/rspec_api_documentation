Then /the outputted docs should( not)? filter out headers$/ do |condition|
  visit "/foobars/getting_foo.html"

  within("pre.curl") do
    if condition
      expect(page).to have_content("Host")
      expect(page).to have_content("Cookie")
    else
      expect(page).to_not have_content("Host")
      expect(page).to_not have_content("Cookie")
    end
  end
end
