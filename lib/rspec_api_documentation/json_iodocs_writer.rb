module RspecApiDocumentation
  class JsonIodocsWriter
    attr_accessor :index, :configuration
    delegate :docs_dir, :to => :configuration

    def initialize(index, configuration)
      self.index = index
      self.configuration = configuration
    end

    def self.write(index, configuration)
      writer = new(index, configuration)
      writer.write
    end

    def endpoints
      index.examples.inject([]) do |collection, example|
        point = collection.select { |ex| ex[:name] == example.resource_name }.first
        if point
          point[:methods] << EndpointMethod.new(example, configuration).to_json
        else
          collection << {
            :name => example.resource_name,
            :methods => [EndpointMethod.new(example, configuration).to_json]
          }
        end
        collection
      end
    end

    def write
      File.open(docs_dir.join("apiconfig.json"), "w+") do |f|
        f.write ApiConfig.new(index, configuration).to_json
      end
      File.open(docs_dir.join("#{configuration.api_key}.json"), "w+") do |f|
        f.write({ :endpoints => endpoints }.to_json)
      end
    end
  end

  class EndpointMethod
    def initialize(example, configuration)
      @example = example
      @configuration = configuration
    end

    def format_param
      {
        "Name" => "format",
        "Required" => "Y",
        "Default" => @configuration.api_formats.first,
        "Type" => "enumerated",
        "Description" => "Output format (#{@configuration.api_formats.join(', ')})",
        "EnumeratedList" => @configuration.api_formats
      }
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
      if @configuration.api_formats.present?
        params << format_param
      end
      params
    end

    def to_json
      {
        "MethodName" => @example.description,
        "Synopsis" => @example.explanation,
        "HTTPMethod" => @example.metadata[:method].to_s.upcase,
        "URI" => @example.metadata[:route] + ".:format",
        "RequiresOAuth" => "N",
        "parameters" => parameters
      }
    end

  end

  class ApiConfig
    def initialize(index, configuration)
      @index = index
      @configuration = configuration
    end

    def protocol
      "http"
    end

    def to_json
      {
        @configuration.api_key.to_sym => {
          :name => @configuration.api_name || "API Documentation",
          :protocol => protocol,
          :publicPath => "",
          :baseURL => @configuration.curl_host.gsub("#{protocol}://","")
        }
      }.to_json
    end

  end
end
