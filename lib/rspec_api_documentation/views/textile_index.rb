module RspecApiDocumentation
  module Views
    class TextileIndex < MarkupIndex
      def initialize(index, configuration)
        super
        self.template_name = "rspec_api_documentation/textile_index"
      end
    end
  end
end
