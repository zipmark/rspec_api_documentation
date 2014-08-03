module RspecApiDocumentation
  module Views
    class HtmlExample < MarkupExample
      EXTENSION = 'html'

      def initialize(index, example, configuration)
        super
        @index = index
        @configuration = configuration
        self.template_name = "rspec_api_documentation/html_example"
      end

      def extension
        EXTENSION
      end

      def api_name
        @configuration.api_name
      end

      def sections
        RspecApiDocumentation::Writers::IndexHelper.sections(examples, @configuration)
      end

      def examples
        @index.examples.map { |example| HtmlExample.new(@index, example, @configuration) }
      end
    end
  end
end
