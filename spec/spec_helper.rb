require 'rspec_api_documentation'
require 'fakefs/spec_helpers'
require 'rspec/its'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers
end
