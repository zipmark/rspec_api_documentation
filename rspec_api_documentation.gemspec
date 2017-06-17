lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "rspec_api_documentation"
  s.version     = "5.1.0"
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
  s.add_runtime_dependency "mustache", "~> 1.0"

  s.add_development_dependency "bundler", "~> 1.0"
  s.add_development_dependency "fakefs", "~> 0.11.0"
  s.add_development_dependency "sinatra", "~> 1.4", ">= 1.4.4"
  s.add_development_dependency "aruba", "~> 0.14.2"
  s.add_development_dependency "capybara", "~> 2.14"
  s.add_development_dependency "rake", "~> 10.1"
  s.add_development_dependency "rack-test", "~> 0.6.3"
  s.add_development_dependency "rack-oauth2", "~> 1.6"
  s.add_development_dependency "webmock", "~> 1.7"
  s.add_development_dependency "rspec-its", "~> 1.2"
  s.add_development_dependency "faraday", "~> 0.12.1"
  s.add_development_dependency "thin", "~> 1.7"

  s.files        = Dir.glob("lib/**/*") + Dir.glob("templates/**/*")
  s.require_path = "lib"
end
