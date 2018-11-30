module RspecApiDocumentation
  module OpenApi
    class Schema < Node
      add_setting :format
      add_setting :title
      add_setting :description
      add_setting :required
      add_setting :enum
      add_setting :type
      add_setting :items
      add_setting :properties
      add_setting :example
    end
  end
end
