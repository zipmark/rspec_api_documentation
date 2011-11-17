module RspecApiDocumentation
  extend ActiveSupport::Autoload

  require 'rspec_api_documentation/railtie' if defined?(Rails)
  include ActiveSupport::JSON

  eager_autoload do
    autoload :ConfigurationSet
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

  def self.configurations
    @configurations ||= ConfigurationSet.new
  end

  def self.configure
    yield configurations if block_given?
  end
end
