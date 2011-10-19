load 'tasks/docs.rake'

module RspecApiDocumentation
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :ApiDocumentation
    autoload :DocumentResource
    autoload :ApiFormatter
    autoload :Example
    autoload :ExampleGroup
    autoload :TestClient
  end
end
