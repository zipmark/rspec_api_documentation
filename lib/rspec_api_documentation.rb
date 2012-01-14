require 'active_support'

module RspecApiDocumentation
  extend ActiveSupport::Autoload

  require 'rspec_api_documentation/railtie' if defined?(Rails)
  include ActiveSupport::JSON

  eager_autoload do
    autoload :Configuration
    autoload :ApiDocumentation
    autoload :DocumentResource
    autoload :ApiFormatter
    autoload :Example
    autoload :ExampleGroup
    autoload :Index
    autoload :TestClient
  end

  autoload :DSL
  autoload :TestServer
  autoload :HtmlWriter
  autoload :JsonWriter
  autoload :IndexWriter

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.documentations
    @documentations ||= configuration.to_a.map { |config| ApiDocumentation.new(config) }
  end

  def self.configure
    yield configuration if block_given?
  end
end
