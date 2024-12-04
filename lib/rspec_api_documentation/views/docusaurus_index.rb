module RspecApiDocumentation
  module Views
    class DocusaurusIndex < MarkupIndex
      SPECIAL_CHARS = /[<>:"\/\\|?*]/.freeze

      def initialize(index, configuration)
        super
        self.template_name = 'custom/docusaurus_index'
      end

      def examples
        @index.examples.map { |example| DocusaurusExample.new(example, @configuration) }
      end

      def id
        sanitize(api_name.to_s).downcase.underscore
      end

      def sanitize(name)
        name.gsub(/\s+/, '_').gsub(SPECIAL_CHARS, '')
      end
    end
  end
end
