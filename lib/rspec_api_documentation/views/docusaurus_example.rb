module RspecApiDocumentation
  module Views
    class DocusaurusExample < MarkupExample
      EXTENSION = 'md'

      def initialize(example, configuration)
        super
        self.template_name = 'custom/docusaurus_example'
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

      def id
        "#{dirname}_#{description.downcase}"
      end

      def response_format
        JSON.parse(response_body)
        'json'
      rescue JSON::ParserError
        nil
      end
    end
  end
end
