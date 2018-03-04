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
              :key => param[:name],
              :equals => true,
              :description => (param[:required] ? "Required" : "") +  param[:description]
            }
          end
        end
        query_params
      end

      def content_type
        { :key => 'Content-Type', :value => @metadata[:request_headers]['Content-Type'] }
      end

      def body
        case content_type[:value]
        when 'application/json'
          @metadata[:request_body] ? { :mode => 'raw', :raw => @metadata[:request_body] } : {}
        when 'w-www-form-urlencoded'
          @metadata[:request_body] ? { :mode => 'urlencoded', :urlencoded => @metadata[:request_body] } : {}
        else
          @metadata[:request_body]
        end
      end

      def as_json(ots = nil)
        {
          :name => description,
          :request => {
            :method => http_method,
            :header => [content_type],
            :body => body,
            :url => {
              :host => ['{{application_url}}'],
              :path => route.split('/').reject { |p| p.empty? },
              :query => populate_query,
              :variable => []
            },
            :description => explanation
          },
          :response => []
        }
      end
    end
  end
end