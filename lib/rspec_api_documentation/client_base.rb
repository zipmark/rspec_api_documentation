module RspecApiDocumentation
  class ClientBase < Struct.new(:context, :options)
    include Headers
    include Syntax

    delegate :example, :app, :to => :context
    delegate :metadata, :to => :example

    def get(*args)
      process :get, *args
    end

    def post(*args)
      process :post, *args
    end

    def put(*args)
      process :put, *args
    end

    def delete(*args)
      process :delete, *args
    end

    private

    def process(method, path, params = {})
      do_request(method, path, params)
      document_example(method.to_s.upcase, path, params)
    end

    def document_example(method, path, params)
      return unless metadata[:document]

      input = last_request.env["rack.input"]
      input.rewind
      request_body = input.read

      request_metadata = {}

      request_metadata[:request_method] = method
      request_metadata[:request_path] = path
      request_metadata[:request_body] = highlight_syntax(request_body, content_type, true)
      request_metadata[:request_headers] = format_headers(request_headers)
      request_metadata[:request_query_parameters] = format_query_hash(query_hash)
      request_metadata[:response_status] = status
      request_metadata[:response_status_text] = Rack::Utils::HTTP_STATUS_CODES[status]
      request_metadata[:response_body] = highlight_syntax(response_body, response_headers['Content-Type'])
      request_metadata[:response_headers] = format_headers(response_headers)
      request_metadata[:curl] = Curl.new(method, path, request_body, request_headers)

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata
    end

    def query_hash
      strings = query_string.split("&")
      arrays = strings.map do |segment|
        segment.split("=")
      end
      Hash[arrays]
    end

    def format_query_hash(query_hash)
      return if query_hash.blank?
      query_hash.map do |key, value|
        "#{key}: #{CGI.unescape(value)}"
      end.join("\n")
    end

    def headers(method, path, params)
      if options && options[:headers]
        options[:headers]
      else
        {}
      end
    end
  end
end
