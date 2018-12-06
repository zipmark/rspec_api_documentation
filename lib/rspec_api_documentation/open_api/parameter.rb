module RspecApiDocumentation
  module OpenApi
    class Parameter < Node
      add_setting :name, :required => true
      add_setting :in, :required => true
      add_setting :description
      add_setting :required, :default => lambda { |parameter| parameter.in.to_s == 'path' }
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
