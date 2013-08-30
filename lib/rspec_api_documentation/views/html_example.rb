module RspecApiDocumentation
  module Views
    class HtmlExample < MarkupExample
      EXTENSION = 'html'

      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/html_example"
      end

      def extension
        EXTENSION
      end
    end
  end
end
