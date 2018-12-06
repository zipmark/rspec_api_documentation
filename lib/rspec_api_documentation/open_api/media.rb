module RspecApiDocumentation
  module OpenApi
    class Media < Node
      add_setting :schema, :schema => Schema
      add_setting :example
      # add_setting :examples, :schema => { '' => Example }
      # add_setting :encoding, :schema => { '' => Encoding }
    end
  end
end
