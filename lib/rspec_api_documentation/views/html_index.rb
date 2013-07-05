require 'mustache'

module RspecApiDocumentation
  module Views
    class HtmlIndex < Mustache
      def initialize(index, configuration)
        @index = index
        @configuration = configuration
        self.template_path = configuration.template_path
        self.template_name = "rspec_api_documentation/html_index"
      end

      def api_name
        @configuration.api_name
      end

      def sections
        RspecApiDocumentation::Writers::IndexWriter.sections(examples, @configuration)
      end

      def examples
        @index.examples.map { |example| HtmlExample.new(example, @configuration) }
      end
    end
  end
end
