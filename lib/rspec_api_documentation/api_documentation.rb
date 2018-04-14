require 'rspec_api_documentation/writers/json_iodocs_writer'

module RspecApiDocumentation
  class ApiDocumentation
    attr_reader :configuration, :index

    delegate :docs_dir, :format, :to => :configuration

    def initialize(configuration)
      @configuration = configuration
      @index = Index.new
    end

    def clear_docs
      writers.each do |writer|
        writer.clear_docs(docs_dir)
      end
    end

    def document_example(rspec_example)
      example = Example.new(rspec_example, configuration)
      if example.should_document?
        index.examples << example
      end
    end

    def write
      writers.each do |writer|
        writer.write(index, configuration)
      end
    end

    def writers
      [*configuration.format].map do |format|
        RspecApiDocumentation::Writers.const_get("#{format}_writer".classify)
      end
    end
  end
end
