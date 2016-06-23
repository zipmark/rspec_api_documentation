module RspecApiDocumentation
  module Views
    class MarkdownExample < MarkupExample
      EXTENSION = 'markdown'

      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/markdown_example"
      end

      def parameters
        super.each do |parameter|
          parameter[:required] = parameter[:required] ? 'true' : 'false'
        end
      end

      def extension
        EXTENSION
      end
    end
  end
end
