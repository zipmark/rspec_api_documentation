require "rspec_api_documentation/dsl/resource"
require "rspec_api_documentation/dsl/endpoint"
require "rspec_api_documentation/dsl/callback"

def self.resource(*args, &block)
  options = if args.last.is_a?(Hash) then args.pop else {} end
  options[:api_doc_dsl] = :resource
  options[:resource_name] = args.first
  options[:document] ||= :all
  args.push(options)
  describe(*args, &block)
end

RSpec.configuration.include RspecApiDocumentation::DSL::Resource, :api_doc_dsl => :resource
RSpec.configuration.include RspecApiDocumentation::DSL::Endpoint, :api_doc_dsl => :endpoint
RSpec.configuration.include RspecApiDocumentation::DSL::Callback, :api_doc_dsl => :callback
RSpec.configuration.backtrace_exclusion_patterns << %r{lib/rspec_api_documentation/dsl\.rb}
