module RspecApiDocumentation
  module OpenApi
    class Server < Node
      add_setting :url, :required => true
      add_setting :description
      add_setting :variables, :schema => { '' => Variable }
    end
  end
end
