module RspecApiDocumentation
  class Example
    include DocumentResource

    attr_accessor :example

    def initialize(example)
      @example = example
    end

    def method_missing(method_sym, *args, &block)
      example.send(method_sym, *args, &block)
    end

    def filename
      description.downcase.gsub(/\s+/, '_').gsub(/[^a-z_]/, '') + ".html"
    end

    def dirname
      ExampleGroup.new(example.example_group).dirname
    end

    def filepath(base_dir)
      base_dir.join(dirname, filename)
    end

    def should_document?
      !pending? && metadata[:resource_name] && metadata[:document]
    end

    def render(template)
      Mustache.render(template, metadata)
    end

    def public?
      metadata[:public]
    end
  end
end
