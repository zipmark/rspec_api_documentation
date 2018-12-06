module RspecApiDocumentation
  module OpenApi
    class Info < Node
      add_setting :title, :default => 'OpenAPI Specification', :required => true
      add_setting :description
      add_setting :termsOfService
      add_setting :contact, :schema => Contact
      add_setting :license, :schema => License
      add_setting :version, :default => '1.0.0', :required => true
    end
  end
end
