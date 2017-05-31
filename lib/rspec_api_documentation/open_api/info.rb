module RspecApiDocumentation
  module OpenApi
    class Info < Node
      add_setting :title, :default => 'OpenAPI Specification', :required => true
      add_setting :description, :default => 'This is a sample server Petstore server.'
      add_setting :termsOfService, :default => 'http://open-api.io/terms/'
      add_setting :contact, :default => Contact.new, :schema => Contact
      add_setting :license, :default => License.new, :schema => License
      add_setting :version, :default => '1.0.0', :required => true
    end
  end
end
