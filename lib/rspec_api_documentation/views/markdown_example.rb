module RspecApiDocumentation
  module Views
    class MarkdownExample < MarkupExample
      EXTENSION = 'markdown'

      def initialize(index, example, configuration)
        super
        self.template_name = "rspec_api_documentation/markdown_example"
      end

      def extension
        EXTENSION
      end
    end
  end
end
