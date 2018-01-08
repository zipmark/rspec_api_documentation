module RspecApiDocumentation
  module Views
    class MarkdownExample < MarkupExample
      EXTENSION = 'md'

      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/markdown_example"
      end

      def parameters
        super.map do |parameter|
          parameter.merge({
            :required => parameter[:required] ? 'true' : 'false',
          })
        end
      end

      def extension
        EXTENSION
      end
    end
  end
end
