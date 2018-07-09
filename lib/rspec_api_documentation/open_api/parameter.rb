module RspecApiDocumentation
  module OpenApi
    class Parameter < Node
      # Required to write example values to description of parameter when option `with_example: true` is provided
      attr_accessor :value
      attr_accessor :with_example

      add_setting :name, :required => true
      add_setting :in, :required => true
      add_setting :description, :default => ''
      add_setting :required, :default => lambda { |parameter| parameter.in.to_s == 'path' ? true : false }
      add_setting :schema
      add_setting :type
      add_setting :items
      add_setting :default
      add_setting :minimum
      add_setting :maximum
      add_setting :enum

      def description_with_example
        str = description_without_example.dup || ''
        if with_example && value
          str << "\n" unless str.empty?
          str << "Eg, `#{value}`"
        end
        str
      end

      alias_method :description_without_example, :description
      alias_method :description, :description_with_example
    end
  end
end
