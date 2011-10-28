module RspecApiDocumentation
  class Example < Mustache
    include DocumentResource

    attr_reader :example, :configuration

    def initialize(example, configuration)
      @example = example
      @configuration = configuration
      self.template_path = configuration.template_path
      self.template_extension = configuration.template_extension
    end

    def method_missing(method_sym, *args, &block)
      if example.metadata.has_key?(method_sym)
        example.metadata[method_sym]
      else
        example.send(method_sym, *args, &block)
      end
    end

    def respond_to?(method_sym, include_private = false)
      super || example.metadata.has_key?(method_sym) || example.respond_to?(method_sym, include_private)
    end

    def method
      metadata[:method]
    end

    def dirname
      resource_name.downcase.gsub(/\s+/, '_')
    end

    def filename
      basename = description.downcase.gsub(/\s+/, '_').gsub(/[^a-z_]/, '')
      "#{basename}.#{configuration.example_extension}"
    end

    def should_document?
      !pending? && metadata[:resource_name] && metadata[:document]
    end

    def public?
      metadata[:public]
    end

    def json
      {
        :resource => resource_name,
        :description => description,
        :request => {
          :headers => request_headers,
          :method => method,
          :route => route,
          :parameters => parameters
        },
        :response => {
          :headers => response_headers,
          :status => response_status,
          :body => response_body
        }
      }.to_json
    end
  end
end
