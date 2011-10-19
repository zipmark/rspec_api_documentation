module RspecApiDocumentation
  extend ActiveSupport::Autoload

  require 'rspec_api_documentation/railtie' if defined?(Rails)

  eager_autoload do
    autoload :ApiDocumentation
    autoload :DocumentResource
    autoload :ApiFormatter
    autoload :Example
    autoload :ExampleGroup
    autoload :TestClient
  end
end
