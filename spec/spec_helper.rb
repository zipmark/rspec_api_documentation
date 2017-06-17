require 'rspec_api_documentation'
require 'fakefs/spec_helpers'
require 'rspec/core/sandbox'
require 'rspec/its'
require 'pry'

# Because testing RSpec with RSpec tries to modify the same global
# objects, we sandbox every test.
RSpec.configure do |config|
  config.around do |ex|
    RSpec::Core::Sandbox.sandboxed do |sandboxed_config|
      # If there is an example-within-an-example, we want to make sure the inner example
      # does not get a reference to the outer example (the real spec) if it calls
      # something like `pending`
      sandboxed_config.before(:context) { RSpec.current_example = nil }

      # Because sandboxed_config is a new instance of RSpec.configuration,
      # we need to include modules added via "rspec_api_documentation/dsl"
      # to the global config object
      sandboxed_config.instance_variable_set :@include_modules, config.instance_variable_get(:@include_modules)

      sandboxed_config.color_mode = :off

      orig_load_path = $LOAD_PATH.dup
      ex.run
      $LOAD_PATH.replace(orig_load_path)
    end
  end
end
