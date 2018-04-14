module RspecApiDocumentation
  module Views
    class SlateIndex < MarkdownIndex
      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/slate_index"
      end
    end
  end
end
