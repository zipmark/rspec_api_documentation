require 'rspec_api_documentation/writers/formatter'

module RspecApiDocumentation
  module Writers
    class JsonIodocsWriter
      attr_accessor :index, :configuration, :api_key
      delegate :docs_dir, :to => :configuration

      def initialize(index, configuration)
        self.index = index
        self.configuration = configuration
        self.api_key = configuration.api_name.parameterize
      end

      def self.write(index, configuration)
        writer = new(index, configuration)
        writer.write
      end

      def write
        File.open(docs_dir.join("apiconfig.json"), "w+") do |file|
          file.write Formatter.to_json(ApiConfig.new(configuration))
        end
        File.open(docs_dir.join("#{api_key}.json"), "w+") do |file|
          file.write Formatter.to_json(JsonIndex.new(index, configuration))
        end
      end
    end

    class JsonIndex
      def initialize(index, configuration)
        @index = index
        @configuration = configuration
      end

      def sections
        IndexWriter.sections(examples, @configuration)
      end

      def examples
        @index.examples.map { |example| JsonExample.new(example, @configuration) }
      end

      def as_json(opts = nil)
        sections.inject({:endpoints => []}) do |h, section|
          h[:endpoints].push(
            :name => section[:resource_name],
            :methods => section[:examples].map do |example|
              example.as_json(opts)
            end
          )
          h
        end
      end
    end

    class JsonExample
      def initialize(example, configuration)
        @example = example
      end

      def method_missing(method, *args, &block)
        @example.send(method, *args, &block)
      end

      def parameters
        params = []
        if @example.respond_to?(:parameters)
          @example.parameters.map do |param|
            params << {
              "Name" => param[:name],
              "Description" => param[:description],
              "Default" => "",
              "Required" => param[:required] ? "Y" : "N"
            }
          end
        end
        params
      end

      def as_json(opts = nil)
         {
          :MethodName => description,
          :Synopsis => explanation,
          :HTTPMethod => http_method,
          :URI => (requests.first[:request_path] rescue ""),
          :RequiresOAuth => "N",
          :parameters => parameters
        }
      end
    end

    class ApiConfig
      def initialize(configuration)
        @configuration = configuration
        @api_key = configuration.api_name.parameterize
      end

      def as_json(opts = nil)
        {
          @api_key.to_sym => {
            :name => @configuration.api_name,
            :protocol => "http",
            :publicPath => "",
            :baseURL => @configuration.curl_host
          }
        }
      end
    end
  end
end
