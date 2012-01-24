require 'rspec_api_documentation'
require 'active_support/inflector'
require 'fakefs/spec_helpers'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
end
