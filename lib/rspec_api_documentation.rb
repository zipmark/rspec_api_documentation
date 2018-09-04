require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext/hash/conversions'
require 'active_support/core_ext/hash/deep_merge'
require 'cgi'
require 'json'

# Namespace for RspecApiDocumentation
module RspecApiDocumentation
  extend ActiveSupport::Autoload

  require 'rspec_api_documentation/railtie' if defined?(Rails::Railtie)
  include ActiveSupport::JSON

  eager_autoload do
    autoload :Configuration
    autoload :ApiDocumentation
    autoload :ApiFormatter
    autoload :Example
    autoload :Index
    autoload :ClientBase
    autoload :Headers
    autoload :HttpTestClient
  end

  autoload :DSL
  autoload :RackTestClient
  autoload :OAuth2MACClient, "rspec_api_documentation/oauth2_mac_client"
  autoload :TestServer
  autoload :Curl

  module Writers
    extend ActiveSupport::Autoload

    autoload :Writer
    autoload :GeneralMarkupWriter
    autoload :HtmlWriter
    autoload :TextileWriter
    autoload :MarkdownWriter
    autoload :JSONWriter
    autoload :JsonWriter
    autoload :AppendJsonWriter
    autoload :JsonIodocsWriter
    autoload :IndexHelper
    autoload :CombinedTextWriter
    autoload :CombinedJsonWriter
    autoload :SlateWriter
    autoload :ApiBlueprintWriter
    autoload :OpenApiWriter
  end

  module OpenApi
    extend ActiveSupport::Autoload

    autoload :Helper
    autoload :Node
    autoload :Root
    autoload :Info
    autoload :Contact
    autoload :License
    autoload :Paths
    autoload :Path
    autoload :Tag
    autoload :Operation
    autoload :Parameter
    autoload :Responses
    autoload :Response
    autoload :Example
    autoload :Headers
    autoload :Header
    autoload :Schema
    autoload :SecurityDefinitions
    autoload :SecuritySchema
  end

  module Views
    extend ActiveSupport::Autoload

    autoload :MarkupIndex
    autoload :MarkupExample
    autoload :HtmlIndex
    autoload :HtmlExample
    autoload :TextileIndex
    autoload :TextileExample
    autoload :MarkdownIndex
    autoload :MarkdownExample
    autoload :SlateIndex
    autoload :SlateExample
    autoload :ApiBlueprintIndex
    autoload :ApiBlueprintExample
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.documentations
    @documentations ||= configuration.map { |config| ApiDocumentation.new(config) }
  end

  # Configures RspecApiDocumentation
  #
  # See RspecApiDocumentation::Configuration for more information on configuring.
  #
  #   RspecApiDocumentation.configure do |config|
  #     config.docs_dir = "doc/api"
  #   end
  def self.configure
    yield configuration if block_given?
  end
end
