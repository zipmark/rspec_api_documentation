require 'active_support'
require 'active_support/inflector'
require 'cgi'
require 'json'

module RspecApiDocumentation
  extend ActiveSupport::Autoload

  require 'rspec_api_documentation/railtie' if defined?(Rails)
  include ActiveSupport::JSON

  eager_autoload do
    autoload :Configuration
    autoload :ApiDocumentation
    autoload :ApiFormatter
    autoload :Example
    autoload :Index
    autoload :ClientBase
    autoload :Headers
  end

  autoload :DSL
  autoload :RackTestClient
  autoload :OAuth2MACClient, "rspec_api_documentation/oauth2_mac_client"
  autoload :TestServer
  autoload :Curl

  module Writers
    extend ActiveSupport::Autoload

    autoload :GeneralMarkupWriter
    autoload :HtmlWriter
    autoload :JsonWriter
    autoload :JsonIodocsWriter
    autoload :IndexWriter
    autoload :CombinedTextWriter
    autoload :CombinedJsonWriter
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.documentations
    @documentations ||= configuration.map { |config| ApiDocumentation.new(config) }
  end

  def self.configure
    yield configuration if block_given?
  end
end
