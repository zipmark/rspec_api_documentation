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
          request[:request_body]  = body_to_json(request, :request)
          request[:response_body] = body_to_json(request, :response)

          request[:request_body] = indent(request[:request_body])
          request[:request_headers_text] = indent(request[:request_headers_text])
          request[:response_body] = indent(request[:response_body])
          request[:response_headers_text] = indent(request[:response_headers_text])
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

      # http_call: the hash that contains all information about the HTTP
      #            request and response.
      # message_direction: either `request` or `response`.
      def body_to_json(http_call, message_direction)
        content_type = http_call["#{message_direction}_content_type".to_sym]
        body         = http_call["#{message_direction}_body".to_sym] # e.g request_body

        if content_type =~ /application\/.*json/ && body
          body = JSON.pretty_generate(JSON.parse(body))
        end

        body
      end
    end
  end
end
