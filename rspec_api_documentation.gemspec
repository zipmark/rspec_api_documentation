lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "rspec_api_documentation"
  s.version     = "0.4.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Cahoon", "Sam Goldman", "Eric Oestrich"]
  s.email       = ["chris@smartlogicsolutions.com", "sam@smartlogicsolutions.com", "eric@smartlogicsolutions.com"]
  s.summary     = "A double black belt for your docs"
  s.description = "Generate API docs from your test suite"
  s.homepage    = "http://smartlogicsolutions.com"

  s.required_rubygems_version = ">= 1.3.6"

  # If adding, please consider gemfiles/minimum_dependencies
  s.add_runtime_dependency "rspec", ">= 2.6.0"
  s.add_runtime_dependency "activesupport", ">= 3.0.0"
  s.add_runtime_dependency "i18n", ">= 0.1.0"
  s.add_runtime_dependency "rack-test", ">= 0.5.5"
  s.add_runtime_dependency "mustache", ">= 0.99.0"
  s.add_runtime_dependency "webmock", ">= 1.7.0"
  s.add_runtime_dependency "json", ">= 1.4.0"

  s.add_development_dependency "fakefs"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "builder"
  s.add_development_dependency "aruba"
  s.add_development_dependency "capybara"
  s.add_development_dependency "rake"

  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
