module RspecApiDocumentation
  class ExampleGroup
    include DocumentResource

    attr_accessor :example_group

    def initialize(example_group)
      @example_group = example_group
    end

    def method_missing(method_sym, *args, &block)
      example_group.send(method_sym, *args, &block)
    end

    def dirname
      resource_name.downcase.gsub(/\s+/, '_')
    end

    def documented_examples
      examples.select { |e| Example.new(e).should_document? }
    end

    def public_examples
      documented_examples.select { |e| Example.new(e).public? }
    end

    def document_example(text)
      metadata[:documentation] = text
    end

    def symlink_public_examples
      public_dir = RspecApiDocumentation::ApiDocumentation.public_docs_dir.join(dirname)
      private_dir = RspecApiDocumentation::ApiDocumentation.docs_dir.join(dirname)

      unless public_examples.empty?
        FileUtils.mkdir_p public_dir
      end

      public_examples.each do |example|
        example = Example.new(example)
        FileUtils.ln_s(private_dir.join(example.filename), public_dir.join(example.filename))
      end
    end
  end
end
