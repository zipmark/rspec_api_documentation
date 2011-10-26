module RspecApiDocumentation
  class ApiDocumentation
    attr_reader :configuration, :examples, :private_index, :public_index

    delegate :docs_dir, :public_docs_dir, :template_path, :template_extension, :private_index_extension, :public_index_extension, :example_extension, :to => :configuration

    def initialize(configuration)
      @configuration = configuration
      @examples = []
      @private_index = Index.new(configuration)
      @public_index = Index.new(configuration)
    end

    def clear_docs
      [docs_dir, public_docs_dir].each do |dir|
        if File.exists?(dir)
          FileUtils.rm_rf(dir, :secure => true)
        end
        FileUtils.mkdir_p(dir)
      end
    end

    def document_example(example)
      wrapped_example = Example.new(example, configuration)
      if wrapped_example.should_document?
        examples << wrapped_example
        private_index.add_example(example)
        public_index.add_example(example) if wrapped_example.public?
      end
    end

    def write_private_index
      file = File.join(docs_dir, "index.#{private_index_extension}")

      private_index.template_path = template_path
      private_index.template_extension = template_extension

      FileUtils.mkdir_p(docs_dir)
      File.open(file, 'w') { |f| f.write private_index.render }
    end

    def write_public_index
      file = File.join(public_docs_dir, "index.#{public_index_extension}")

      public_index.template_path = template_path
      public_index.template_extension = template_extension

      FileUtils.mkdir_p(public_docs_dir)
      File.open(file, 'w') { |f| f.write public_index.render }
    end

    def write_examples
      examples.each do |example|
        write_example(example)
      end
    end

    def write_example(wrapped_example)
      dir = docs_dir.join(wrapped_example.dirname)
      file = dir.join("#{wrapped_example.filename}.#{example_extension}")

      wrapped_example.template_path = template_path
      wrapped_example.template_extension = template_extension

      FileUtils.mkdir_p(dir)
      File.open(file, 'w') { |f| f.write wrapped_example.render }
    end

    def symlink_public_examples
      public_index.examples.each do |example|
        FileUtils.mkdir_p(File.join(public_docs_dir, example.dirname))
        filename = "#{example.filename}.#{example_extension}"
        private_doc = File.join(docs_dir, example.dirname, filename)
        public_doc = File.join(public_docs_dir, example.dirname, filename)
        FileUtils.ln_s(private_doc, public_doc)
      end
    end
  end
end
