module RspecApiDocumentation
  module Views
    class PostmanRequestMetadata
      attr_reader :example, :metadata

      def initialize(example)
        @example = example
        @metadata = requests.first
      end

      def method_missing(method, *args, &block)
        example.send(method, *args, &block)
      end

      def query_in_url
        query_params = []

        if metadata[:request_query_parameters] && example.respond_to?(:parameters)
          metadata[:request_query_parameters].map do |k, v|
            documented_param = example.parameters.select { |p| p[:name] == k.to_s }.try(:first)
            if documented_param
              query_params << { key: k.to_s,
                                value: '',
                                equals: true,
                                description: format_description(documented_param[:description],
                                                                documented_param[:required]),
                                disabled: !documented_param[:required]
              }
            end
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

      def variables_for_url
        route_variables = tokenized_path.select { |r| r.start_with?(':') }
        return [] unless route_variables

        variables = []
        route_variables.each do |rv|
          param_name = rv.split(':')[1]
          param_from_example = example.parameters.select { |e| e[:name] == param_name }.try(:first)
          if param_from_example
            variable = {
              key: param_name,
              value: '',
              description: format_description(param_from_example[:description],
                                              param_from_example[:required]),
              disabled: !param_from_example[:required]

            }
            variables << variable
          end
        end

        variables
      end

      def request_description
        text = explanation ? explanation : ""
        if example.respond_to?(:parameters)
          example.parameters.each do |param|
            text = text + "\n * `#{param[:name]}`: #{param[:description]}"
          end
        end
        text
      end

      def tokenized_path
        route.split('/').reject { |p| p.empty? }
      end

      private

      def build_urlencoded_body
        urlencoded_params = []
        params = CGI::parse(metadata[:request_body])
        params.each do |p|
          param_from_example = example.parameters.select{ |e| e[:name] == p.first }.try(:first)
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
