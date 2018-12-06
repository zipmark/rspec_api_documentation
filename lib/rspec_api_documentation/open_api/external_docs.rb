module RspecApiDocumentation
  module OpenApi
    class ExternalDocs < Node
      add_setting :description
      add_setting :url, :required => true
    end
  end
end
