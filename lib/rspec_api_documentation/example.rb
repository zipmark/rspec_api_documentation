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

    def has_response_fields?
      ((respond_to?(:response_fields) && response_fields.present?) || (respond_to?(:fields) && fields.present?))
    end

    def response_fields
      if metadata[:response_fields].present?
        return metadata[:response_fields]
      elsif fields_from_response.present? && !!(configuration.dynamic_response_fields)
        return dynamic_response_fields(fields_from_response)
      else
        []
      end
    end

    def explanation
      metadata[:explanation] || nil
    end

    def requests
      filter_headers(metadata[:requests]) || []
    end

    private

    def filter_headers(requests)
      requests = remap_headers(requests, :request_headers, configuration.request_headers_to_include)
      requests = remap_headers(requests, :response_headers, configuration.response_headers_to_include)
      requests
    end

    def remap_headers(requests, key, headers_to_include)
      return requests unless headers_to_include
      requests.each.with_index do |request_hash, index|
        next unless request_hash.key?(key)
        headers = request_hash[key]
        request_hash[key] = headers.select{ |key, _| headers_to_include.include?(key) }
        requests[index] = request_hash
      end
    end

    def dynamic_response_fields(response, results = [], scope=false)
      response.map do |k, v|
        type = determine_type(v)
        if type == "Array" && determine_type(v.first) == "Hash"
          results  = dynamic_response_fields(v.first, results, k)
        elsif type == "Hash"
          results = dynamic_response_fields(v, results, k)
        else
          result = {name: k, description: k, type: determine_type(v) }
          result.merge!(scope: scope) if !!(scope)
          results.push result
        end
      end
      return results
    end

    def fields_from_response(response = metadata[:requests])
      return [] if response.nil? || response.first[:response_body].nil?
      response = JSON.parse(response.first[:response_body]) rescue response
      return response.is_a?(Hash) ? response : response.is_a?(Array) ? response.first : response
    end

    def determine_type(v)
      return "Integer" if v.is_a?(Integer)
      return "Boolean" if (v == true || v== 'false')
      return "DateTime" if Date.parse(v) rescue false
      return "Hash" if v.is_a?(Hash)
      return "Array" if v.is_a?(Array)
      return "String"
    end
  end
end
