module RspecApiDocumentation
  module Views
    class PostmanRequestExample
      attr_reader :metadata

      def initialize(example)
        @example = example
        @metadata = requests.first
      end

      def method_missing(method, *args, &block)
        @example.send(method, *args, &block)
      end

      def populate_query
        query_params = []
        if @example.respond_to?(:parameters)
          @example.parameters.map do |param|
            query_params << {
              key: param[:name],
              equals: true,
              description: format_description(param[:description], param[:required])
            }
          end
        end
        query_params
      end

      def content_type
        { key: 'Content-Type', value: metadata[:request_headers]['Content-Type'] }
      end

      def body
        return {} unless metadata[:request_body]

        if content_type[:value] == 'application/w-www-form-urlencoded'
          { mode: 'urlencoded', urlencoded: build_urlencoded_body }
        elsif content_type[:value] == 'application/octet-stream'
          { mode: 'file', file: {} }
        else
          { mode: 'raw', raw: metadata[:request_body] }
        end
      end

      def as_json(ots = nil)
        {
          name: description,
          request: {
            method: http_method,
            header: [content_type],
            body: body,
            url: {
              host: ['{{application_url}}'],
              path: route.split('/').reject { |p| p.empty? },
              query: populate_query,
              variable: []
            },
            description: explanation
          },
          response: []
        }
      end

      private

      def build_urlencoded_body
        urlencoded_params = []
        params = CGI::parse(metadata[:request_body])
        params.each do |p|
          param_from_example = @example.parameters.select{ |e| e[:name] == p.first }.try(:first)
          if param_from_example
            urlencoded_param = {
              key: p.first,
              value: '',
              description: format_description(param_from_example[:description],
                                              param_from_example[:required]),
              type: 'text',
              disabled: !param_from_example[:required]
            }
            urlencoded_params << urlencoded_param
          end
        end
        urlencoded_params
      end

      def format_description(description, required = false)
        required ? "Required. #{description}" : description
      end
    end
  end
end