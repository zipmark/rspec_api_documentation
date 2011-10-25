module RspecApiDocumentation
  class Example < Mustache
    include DocumentResource

    attr_accessor :example

    def initialize(example)
      self.example = example
    end

    def method_missing(method_sym, *args, &block)
      example.send(method_sym, *args, &block)
    end

    def respond_to?(method_sym, include_private = false)
      super || example.respond_to?(method_sym, include_private)
    end

    def method
      metadata[:method]
    end

    def example_group
      ExampleGroup.new(example.example_group)
    end

    def dirname
      example_group.dirname
    end

    def filename
      description.downcase.gsub(/\s+/, '_').gsub(/[^a-z_]/, '')
    end

    def should_document?
      !pending? && metadata[:resource_name] && metadata[:document]
    end

    def public?
      metadata[:public]
    end
  end
end
