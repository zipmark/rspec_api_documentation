module RspecApiDocumentation
  module OpenApi
    class Response < Node
      add_setting :description, :required => true, :default => 'Successful operation'
      add_setting :schema, :schema => Schema
      add_setting :headers, :schema => { "" => Header }
      add_setting :examples
    end
  end
end
