require "aruba/cucumber"
require "capybara"

if RUBY_PLATFORM == "java"
  Aruba.configure do |config|
    config.before_cmd do |cmd|
      set_env "JRUBY_OPTS", "-X-C -J-XX:+TieredCompilation -J-XX:TieredStopAtLevel=1 #{ENV["JRUBY_OPTS"]}"
    end
  end
end

Before do
  @aruba_timeout_seconds = if RUBY_PLATFORM == "java"
    60
  else
    5
  end
end

Capybara.configure do |config|
  config.match = :prefer_exact
  config.ignore_hidden_elements = false
end
