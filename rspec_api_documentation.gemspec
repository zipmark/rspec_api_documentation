lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "rspec_api_documentation"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Cahoon", "Sam Goldman", "Eric Oestrich"]
  s.email       = ["chris@smartlogicsolutions.com", "sam@smartlogicsolutions.com", "eric@smartlogicsolutions.com"]
  s.summary     = "A double black belt for your docs"
  s.description = "Generate API docs from your test suite"
  s.homepage    = "http://smartlogicsolutions.com"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency "rspec"
  s.add_runtime_dependency "mustache"
  s.add_runtime_dependency "rails"

  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
