module RspecApiDocumentation
  module OpenApi
    class Operation < Node
      add_setting :tags, :default => []
      add_setting :summary
      add_setting :description
      add_setting :externalDocs, :schema => ExternalDocs
      # add_setting :operationId
      add_setting :parameters, :default => [], :schema => [Parameter]
      add_setting :requestBody, :schema => RequestBody
      add_setting :responses, :required => true, :schema => { '' => Response }
      add_setting :deprecated, :default => false
      add_setting :security
      # add_setting :servers, :schema => [Server]
    end
  end
end
