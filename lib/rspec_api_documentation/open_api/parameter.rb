module RspecApiDocumentation
  module OpenApi
    class Parameter < Node
      # Required to write example values to description of parameter when option `with_example: true` is provided
      attr_accessor :value
      attr_accessor :with_example

      add_setting :name, :required => true
      add_setting :in, :required => true
      add_setting :description
      add_setting :required, :default => lambda { |parameter| parameter.in.to_s == 'path' ? true : false }
      add_setting :schema
      add_setting :type
      add_setting :items
      add_setting :default
      add_setting :minimum
      add_setting :maximum
      add_setting :enum
      add_setting :example, :default => lambda { |parameter| parameter.with_example ? parameter.value : nil }

      alias_method :description_without_example, :description
    end
  end
end
