module RspecApiDocumentation
  module Views
    class TextileExample < MarkupExample
      EXTENSION = 'textile'

      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/textile_example"
      end

      def extension
        EXTENSION
      end
    end
  end
end
