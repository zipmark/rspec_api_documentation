module RspecApiDocumentation
  module OpenApi
    class RequestBody < Node
      add_setting :description, :default => 'body'
      add_setting :content, :required => true, :schema => { '' => Media }
      add_setting :required, :default => false
    end
  end
end
