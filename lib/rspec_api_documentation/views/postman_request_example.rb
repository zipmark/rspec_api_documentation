module RspecApiDocumentation
  module Views
    class PostmanRequestExample
      attr_reader :example, :metadata

      def initialize(example)
        @example = example
        @metadata = Views::PostmanRequestMetadata.new(example)
      end

      def method_missing(method, *args, &block)
        example.send(method, *args, &block)
      end

      def as_json(options = nil)
        {
          name: description,
          request: {
            method: http_method,
            header: [metadata.content_type],
            body: metadata.body,
            url: {
              host: ['{{application_url}}'],
              path: metadata.tokenized_path,
              query: metadata.query_in_url,
              variable: metadata.variables_for_url
            },
            description: metadata.request_description
          },
          response: []
        }
      end
    end
  end
end