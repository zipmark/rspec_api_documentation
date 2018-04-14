module RspecApiDocumentation
  module Views
    class ApiBlueprintExample < MarkupExample
      TOTAL_SPACES_INDENTATION = 12.freeze

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
          request[:request_headers_text]  = remove_utf8_for_json(remove_content_type(request[:request_headers_text]))
          request[:request_headers_text]  = indent(request[:request_headers_text])
          request[:request_content_type]  = content_type(request[:request_headers])
          request[:request_content_type]  = remove_utf8_for_json(request[:request_content_type])
          request[:request_body]          = body_to_json(request, :request)
          request[:request_body]          = indent(request[:request_body])

          request[:response_headers_text] = remove_utf8_for_json(remove_content_type(request[:response_headers_text]))
          request[:response_headers_text] = indent(request[:response_headers_text])
          request[:response_content_type] = content_type(request[:response_headers])
          request[:response_content_type] = remove_utf8_for_json(request[:response_content_type])
          request[:response_body]         = body_to_json(request, :response)
          request[:response_body]         = indent(request[:response_body])

          request[:has_request?]          = has_request?(request)
          request[:has_response?]         = has_response?(request)
          request
        end
      end

      def extension
        Writers::ApiBlueprintWriter::EXTENSION
      end

      private

      # `Content-Type` header is removed because the information would be duplicated
      # since it's already present in `request[:request_content_type]`.
      def remove_content_type(headers)
        return unless headers
        headers
          .split("\n")
          .reject { |header|
            header.start_with?('Content-Type:')
          }
          .join("\n")
      end

      def has_request?(metadata)
        metadata.any? do |key, value|
          [:request_body, :request_headers, :request_content_type].include?(key) && value
        end
      end

      def has_response?(metadata)
        metadata.any? do |key, value|
          [:response_status, :response_body, :response_headers, :response_content_type].include?(key) && value
        end
      end

      def indent(string)
        string.tap do |str|
          str.gsub!(/\n/, "\n" + (" " * TOTAL_SPACES_INDENTATION)) if str
        end
      end

      # http_call: the hash that contains all information about the HTTP
      #            request and response.
      # message_direction: either `request` or `response`.
      def body_to_json(http_call, message_direction)
        content_type = http_call["#{message_direction}_content_type".to_sym]
        body         = http_call["#{message_direction}_body".to_sym] # e.g request_body

        if json?(content_type) && body
          body = JSON.pretty_generate(JSON.parse(body))
        end

        body
      end

      # JSON requests should use UTF-8 by default according to
      # http://www.ietf.org/rfc/rfc4627.txt, so we will remove `charset=utf-8`
      # when we find it to remove noise.
      def remove_utf8_for_json(headers)
        return unless headers
        headers
          .split("\n")
          .map { |header|
            header.gsub!(/; *charset=utf-8/, "") if json?(header)
            header
          }
          .join("\n")
      end

      def content_type(headers)
        headers && headers.fetch("Content-Type", nil)
      end

      def json?(string)
        string =~ /application\/.*json/
      end
    end
  end
end
