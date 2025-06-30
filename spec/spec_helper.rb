require 'rspec_api_documentation'
require 'fakefs/spec_helpers'
require 'rspec/its'
require 'pry'

RspecApiDocumentation.configure do |config|
  config.response_body_formatter = lambda do |response_content_type, response_body|
    if response_content_type&.include?('application/json')
      return JSON.pretty_generate(JSON.parse(response_body))
    elsif response_content_type&.include?('text') || response_content_type&.include?('txt')
      # quote it for JSON Parser in documentation reader like APITOME
      return "\"#{response_body}\""
    else
      return '[binary data]'
    end
  rescue JSON::ParserError
    '[binary data]'
  end
end

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
