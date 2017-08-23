require 'mustache'

module RspecApiDocumentation
  module Views
    class MarkupIndex < Mustache
      delegate :api_name, :api_explanation, to: :@configuration, prefix: false

      def initialize(index, configuration)
        @index = index
        @configuration = configuration
        self.template_path = configuration.template_path
      end

      def sections
        RspecApiDocumentation::Writers::IndexHelper.sections(examples, @configuration)
      end
    end
  end
end
