require 'rspec_api_documentation'
require 'fakefs/spec_helpers'
require 'rspec/its'
require 'pry'

RSpec.configure do |config|
  config.before(:all) do
    if self.class.metadata[:api_doc_dsl] || self.respond_to?(:app)
      begin
        require 'support/stub_app'
        RspecApiDocumentation.configure do |config|
          config.app = StubApp.new unless config.app
        end
      rescue LoadError
        # StubApp not available, skip
      end
    end
  end
end
