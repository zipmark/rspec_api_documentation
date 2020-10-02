lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "rspec_api_documentation"
  s.version     = "6.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Cahoon", "Sam Goldman", "Eric Oestrich"]
  s.email       = ["chris@smartlogicsolutions.com", "sam@smartlogicsolutions.com", "eric@smartlogicsolutions.com"]
  s.summary     = "A double black belt for your docs"
  s.description = "Generate API docs from your test suite"
  s.homepage    = "http://smartlogicsolutions.com"
  s.license     = "MIT"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency "rspec", "~> 3.0"
  s.add_runtime_dependency "activesupport", ">= 3.0.0"
  s.add_runtime_dependency "mustache", "~> 1.0", ">= 0.99.4"

  s.add_development_dependency "bundler", ">= 1.16"
  s.add_development_dependency "fakefs", "~> 0.6.0"
  s.add_development_dependency "sinatra", "~> 1.4.7"
  s.add_development_dependency "aruba", "~> 0.13.0"
  s.add_development_dependency "capybara", "~> 2.6.2"
  s.add_development_dependency "rake", "~> 10.5.0"
  s.add_development_dependency "rack-test", "~> 0.6.3"
  s.add_development_dependency "rack-oauth2", "~> 1.2.2"
  s.add_development_dependency "webmock", "~> 3.8.3"
  s.add_development_dependency "rspec-its", "~> 1.2.0"
  s.add_development_dependency "faraday", "~> 0.9.2"
  s.add_development_dependency "nokogiri", "~> 1.8.4"
  s.add_development_dependency "yard", "~> 0.9.15"
  s.add_development_dependency "inch", "~> 0.8.0"
  s.add_development_dependency "minitest", "~> 5.8.4"
  s.add_development_dependency "contracts", "~> 0.13.0"
  s.add_development_dependency "gherkin", "~> 3.2.0"
  s.add_development_dependency "multi_json", "~> 1.11.2"
  s.add_development_dependency "rspec", "~> 3.4.0"

  s.files        = Dir.glob("lib/**/*") + Dir.glob("templates/**/*")
  s.require_path = "lib"
end
