module RspecApiDocumentation
  class Example
    attr_reader :example, :configuration

    def initialize(example, configuration)
      @example = example
      @configuration = configuration
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

    def http_method
      metadata[:method].to_s.upcase
    end

    def should_document?
      return false if pending? || !metadata[:resource_name] || !metadata[:document]
      return false if (Array(metadata[:document]) & Array(configuration.exclusion_filter)).length > 0
      return true if (Array(metadata[:document]) & Array(configuration.filter)).length > 0
      return true if configuration.filter == :all
    end

    def public?
      metadata[:public]
    end

    def has_parameters?
      respond_to?(:parameters) && parameters.present?
    end

    def explanation
      metadata[:explanation] || nil
    end

    def requests
      reqs = metadata[:requests] || []
      reqs.each do |req|
        if req[:request_headers]["Content-Type"].try(:match, /\Amultipart\/form-data/)
          i = req[:request_body].index /^Content-Disposition: form-data.* filename=\"/
          i = req[:request_body].index "\r\n\r\n", i unless i.nil?
          unless i.nil?
            req[:request_body] = "#{req[:request_body][0..i+3]}...[truncated file data]..."
          end
        end
      end
      reqs
    end
  end
end
