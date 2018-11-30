module RspecApiDocumentation
  module OpenApi
    class Operation < Node
      add_setting :tags, :default => []
      add_setting :summary
      add_setting :description
      add_setting :externalDocs
      add_setting :operationId
      add_setting :consumes
      add_setting :produces
      add_setting :parameters, :default => [], :schema => [Parameter]
      add_setting :responses, :required => true, :schema => Responses
      add_setting :schemes
      add_setting :deprecated, :default => false
      add_setting :security
    end
  end
end
