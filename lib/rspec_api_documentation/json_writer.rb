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
        f.write JsonIndex.new(index).to_json
      end
      index.examples.each do |example|
        json_example = JsonExample.new(example)
        FileUtils.mkdir_p(docs_dir.join(json_example.dirname))
        File.open(docs_dir.join(json_example.dirname, json_example.filename), "w+") do |f|
          f.write json_example.to_json
        end
      end
    end
  end

  class JsonIndex
    def initialize(index)
      @index = index
    end

    def sections
      IndexWriter.sections(examples)
    end

    def examples
      @index.examples.map { |example| JsonExample.new(example) }
    end

    def to_json
      sections.inject({:resources => []}) do |h, section|
        h[:resources].push(
          :name => section[:resource_name],
          :examples => examples.map { |example|
            {
              :description => example.description,
              :link => "#{example.dirname}/#{example.filename}"
            }
          }
        )
        h
      end.to_json
    end
  end

  class JsonExample
    delegate :method, :to => :@example

    def initialize(example)
      @example = example
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

    def to_json
      request = {
        :headers => request_headers,
        :method => method,
        :route => route,
        :parameters => request_body
      } if respond_to?(:request_headers)
      response = {
        :headers => response_headers,
        :status => response_status,
        :body => response_body
      } if respond_to?(:response_status)
      {
        :resource => resource_name,
        :description => description,
        :explanation => explanation,
        :request => request,
        :response => response,
        :parameters => respond_to?(:parametiers) ? parameters : []
      }.to_json
    end
  end
end
