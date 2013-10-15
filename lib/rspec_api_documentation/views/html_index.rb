module RspecApiDocumentation
  module Views
    class HtmlIndex < MarkupIndex
      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/html_index"
      end

      def examples
        @index.examples.map { |example| HtmlExample.new(example, @configuration) }
      end
    end
  end
end
