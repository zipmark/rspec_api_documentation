module RspecApiDocumentation
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
        file.write ApiConfig.new(configuration).to_json
      end
      File.open(docs_dir.join("#{api_key}.json"), "w+") do |file|
        file.write JsonIndex.new(index, configuration).to_json
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

    def to_json
      sections.inject({:endpoints => []}) do |h, section|
        h[:endpoints].push(
          :name => section[:resource_name],
          :methods => section[:examples].map do |example|
            example.to_json
          end
        )
        h
      end.to_json
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

    def to_json
       {
        :MethodName => description,
        :Synopsis => explanation,
        :HTTPMethod => http_method,
        :URI => route,
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

    def to_json
      {
        @api_key.to_sym => {
          :name => @configuration.api_name,
          :protocol => "http",
          :publicPath => "",
          :baseURL => @configuration.curl_host
        }
      }.to_json
    end
  end
end
