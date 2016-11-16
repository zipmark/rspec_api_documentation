module RspecApiDocumentation
  module Views
    class ApiBlueprintExample < MarkupExample
      TOTAL_SPACES_INDENTATION = 8.freeze

      def initialize(example, configuration)
        super
        self.template_name = "rspec_api_documentation/api_blueprint_example"
      end

      def parameters
        super.map do |parameter|
          parameter.merge({
            :required => !!parameter[:required],
            :has_example => !!parameter[:example],
            :has_type => !!parameter[:type]
          })
        end
      end

      def requests
        super.map do |request|
          if request[:request_content_type] =~ /application\/json/ && request[:request_body]
            request[:request_body] = JSON.pretty_generate(JSON.parse(request[:request_body]))
          end

          request[:request_body] = indent(request[:request_body])
          request[:request_body] = indent(request[:request_headers_text])
          request[:request_body] = indent(request[:response_body])
          request[:request_body] = indent(request[:response_headers_text])
          request
        end
      end

      def extension
        Writers::ApiBlueprintWriter::EXTENSION
      end

      private

      def indent(string)
        string.tap do |str|
          if str
            str.gsub!(/\n/, "\n" + (" " * TOTAL_SPACES_INDENTATION))
          end
        end
      end
    end
  end
end
