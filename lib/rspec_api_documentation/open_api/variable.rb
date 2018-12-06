module RspecApiDocumentation
  module OpenApi
    class Variable < Node
      add_setting :enum
      add_setting :default, :required => true
      add_setting :description
    end
  end
end
