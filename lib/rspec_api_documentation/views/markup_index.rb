require 'mustache'

module RspecApiDocumentation
  module Views
    class MarkupIndex < Mustache
      def initialize(index, configuration)
        @index = index
        @configuration = configuration
        self.template_path = configuration.template_path
      end

      def api_name
        @configuration.api_name
      end

      def sections
        RspecApiDocumentation::Writers::IndexHelper.sections(examples, @configuration)
      end
    end
  end
end
