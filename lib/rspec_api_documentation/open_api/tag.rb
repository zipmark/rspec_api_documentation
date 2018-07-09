module RspecApiDocumentation
  module OpenApi
    class Tag < Node
      add_setting :name, :required => true
      add_setting :description, :default => ''
      add_setting :externalDocs
    end
  end
end
