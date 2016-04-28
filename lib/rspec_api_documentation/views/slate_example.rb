module RspecApiDocumentation
  module Views
    class SlateExample < MarkdownExample
      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/slate_example"
      end
    end
  end
end
