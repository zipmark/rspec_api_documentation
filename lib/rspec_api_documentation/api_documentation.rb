module RspecApiDocumentation
  class ApiDocumentation
    attr_reader :configuration, :index

    delegate :docs_dir, :format, :to => :configuration

    def initialize(configuration)
      @configuration = configuration
      @index = Index.new(configuration)
    end

    def clear_docs
      if File.exists?(docs_dir)
        FileUtils.rm_rf(docs_dir, :secure => true)
      end
      FileUtils.mkdir_p(docs_dir)
    end

    def document_example(rspec_example)
      example = Example.new(rspec_example, configuration)
      if example.should_document?
        index.examples << example
      end
    end

    def write_index
      file = File.join(docs_dir, "index.#{format}")

      FileUtils.mkdir_p(docs_dir)
      File.open(file, 'w') { |f| f.write index.render }
    end

    def write_examples
      index.examples.each do |example|
        write_example(example)
      end
    end

    def write_example(wrapped_example)
      dir = docs_dir.join(wrapped_example.dirname)
      file = dir.join(wrapped_example.filename)

      FileUtils.mkdir_p(dir)
      File.open(file, 'w') { |f| f.write wrapped_example.render }
    end
  end
end
