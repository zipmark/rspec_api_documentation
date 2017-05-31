module RspecApiDocumentation
  module OpenApi
    class Root < Node
      add_setting :swagger, :default => '2.0', :required => true
      add_setting :info, :default => Info.new, :required => true, :schema => Info
      add_setting :host, :default => 'localhost:3000'
      add_setting :basePath
      add_setting :schemes, :default => %w(http https)
      add_setting :consumes, :default => %w(application/json application/xml)
      add_setting :produces, :default => %w(application/json application/xml)
      add_setting :paths, :default => Paths.new, :required => true, :schema => Paths
      add_setting :definitions
      add_setting :parameters
      add_setting :responses
      add_setting :securityDefinitions, :schema => SecurityDefinitions
      add_setting :security
      add_setting :tags, :default => [], :schema => [Tag]
      add_setting :externalDocs
    end
  end
end
