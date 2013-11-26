require "aruba/cucumber"
require "capybara"

Before do
  @aruba_timeout_seconds = 5
end

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = false
end
