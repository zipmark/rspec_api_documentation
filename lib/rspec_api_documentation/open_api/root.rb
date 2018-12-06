module RspecApiDocumentation
  module OpenApi
    class Root < Node
      add_setting :openapi, :default => '3.0.0', :required => true
      add_setting :info, :default => Info.new, :required => true, :schema => Info
      add_setting :servers, :schema => [Server]
      add_setting :paths, :default => { '/' => Path.new }, :required => true, :schema => { '' => Path }
      add_setting :components, :schema => Components
      add_setting :security
      add_setting :tags, :schema => [Tag]
      add_setting :externalDocs, :schema => ExternalDocs
    end
  end
end
