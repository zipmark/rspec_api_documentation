module RspecApiDocumentation
  module OpenApi
    class Header < Node
      add_setting :description
      add_setting :required
      add_setting :deprecated
      # add_setting :allowEmptyValue
      # add_setting :style
      # add_setting :explode
      # add_setting :allowReserved
      add_setting :schema, :schema => Schema
      add_setting :example
      # add_setting :examples, :schema => { '' => Example }
      # add_setting :content, :schema => { '' => Media }
    end
  end
end
