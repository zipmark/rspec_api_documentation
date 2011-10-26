module RspecApiDocumentation
  class ExampleGroup < Mustache
    include DocumentResource

    attr_accessor :example_group

    def initialize(example_group)
      self.example_group = example_group
    end

    def method_missing(method_sym, *args, &block)
      example_group.send(method_sym, *args, &block)
    end

    def respond_to?(method_sym, include_private = false)
      super || example_group.respond_to?(method_sym, include_private)
    end

    def eql?(other)
      example_group.eql?(other.example_group)
    end

    def hash
      example_group.hash
    end

    def dirname
      resource_name.downcase.gsub(/\s+/, '_')
    end

    def examples
      example_group.examples.map { |e| Example.new(e) }
    end

    def documented_examples
      examples.select(&:should_document?)
    end

    def public_examples
      documented_examples.select(&:public?)
    end

    def symlink_public_examples
      public_dir = RspecApiDocumentation.configuration.public_docs_dir.join(dirname)
      private_dir = RspecApiDocumentation.configuration.docs_dir.join(dirname)

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
