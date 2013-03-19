module RspecApiDocumentation
  class JsonWriter
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

    def write
      File.open(docs_dir.join("index.json"), "w+") do |f|
        f.write JsonIndex.new(index, configuration).to_json
      end
      index.examples.each do |example|
        json_example = JsonExample.new(example, configuration)
        FileUtils.mkdir_p(docs_dir.join(json_example.dirname))
        File.open(docs_dir.join(json_example.dirname, json_example.filename), "w+") do |f|
          f.write json_example.to_json
        end
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
      sections.inject({:resources => []}) do |h, section|
        h[:resources].push(
          :name => section[:resource_name],
          :examples => section[:examples].map { |example|
            {
              :description => example.description,
              :link => "#{example.dirname}/#{example.filename}",
              :groups => example.metadata[:document]
            }
          }
        )
        h
      end.to_json
    end
  end

  class JsonExample
    def initialize(example, configuration)
      @example = example
      @host = configuration.curl_host
    end

    def method_missing(method, *args, &block)
      @example.send(method, *args, &block)
    end

    def respond_to?(method, include_private = false)
      super || @example.respond_to?(method, include_private)
    end

    def dirname
      resource_name.downcase.gsub(/\s+/, '_')
    end

    def filename
      basename = description.downcase.gsub(/\s+/, '_').gsub(/[^a-z_]/, '')
      "#{basename}.json"
    end

    def as_json
      {
        :resource => resource_name,
        :http_method => http_method,
        :route => route,
        :description => description,
        :explanation => explanation,
        :parameters => respond_to?(:parameters) ? parameters : [],
        :requests => requests
      }
    end

    def to_json
      as_json.to_json
    end

    def requests
      super.map do |hash|
        if @host
          hash[:curl] = hash[:curl].output(@host) if hash[:curl].is_a? RspecApiDocumentation::Curl
        else
          hash[:curl] = nil
        end
        hash
      end
    end
  end
end
