require 'rspec_api_documentation/writers/formatter'

module RspecApiDocumentation
  module Writers
    class PostmanWriter < Writer
      attr_accessor :api_name
      delegate :docs_dir, :to => :configuration

      def initialize(index, configuration)
        super
        self.api_name = configuration.api_name.parameterize
      end

      def write
        File.open(docs_dir.join("#{api_name}.postman_collection.json"), "w+") do |file|
          file.write Formatter.to_json(PostmanIndex.new(index, configuration))
        end
      end
    end

    class PostmanIndex
      POSTMAN_SCHEMA = 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'.freeze

      def initialize(index, configuration)
        @index = index
        @configuration = configuration
      end

      def sections
        IndexHelper.sections(examples, @configuration)
      end

      def examples
        @index.examples.map do |example|
          PostmanRequestExample.new(example)
        end
      end

      def as_json(opts = nil)
        collections = { :info => { :name => @configuration.api_name,
                     :description => @configuration.api_explanation,
                     :schema => POSTMAN_SCHEMA },
          :item => []
        }

        sections.each do |section|
          folder = { :name => section[:resource_name],
                     :description => section[:resource_explanation],
                     :item => section[:examples].map do |example|
                       example.as_json(opts)
                     end
                    }
          collections[:item] << folder
        end

        collections
      end
    end

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

      def as_json(ots = nil)
        {
          :name => description,
          :request => {
            :method => http_method,
            :header => [ { :key => "Content-Type", :value => @metadata[:request_headers]["Content-Type"] } ],
            :body => {},
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