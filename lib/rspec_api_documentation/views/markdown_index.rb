module RspecApiDocumentation
  module Views
    class MarkdownIndex < MarkupIndex
      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/markdown_index"
      end

      def examples
        @index.examples.map { |example| MarkdownExample.new(example, @configuration) }
      end
    end
  end
end
