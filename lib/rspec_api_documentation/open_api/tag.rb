module RspecApiDocumentation
  module OpenApi
    class Tag < Node
      add_setting :name, :required => true
      add_setting :description
      # add_setting :externalDocs, :schema => ExternalDocs
    end
  end
end
