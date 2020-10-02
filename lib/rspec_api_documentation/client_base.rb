module RspecApiDocumentation
  # Base client class that documents all requests that go through it.
  #
  #  client.get("/orders", { :page => 2 }, { "Accept" => "application/json" })
  class ClientBase < Struct.new(:context, :options)
    include Headers

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

    def head(*args)
      process :head, *args
    end

    def patch(*args)
      process :patch, *args
    end

    def response_status
      status
    end

    private

    def process(method, path, params = {}, headers ={})
      do_request(method, path, params, headers)
      document_example(method.to_s.upcase, path)
    end

    def read_request_body
      input = last_request.env["rack.input"]
      input.rewind
      input.read
    end

    def document_example(method, path)
      return unless metadata[:document]

      request_body = read_request_body

      request_metadata = {}

      if request_content_type =~ /multipart\/form-data/ && respond_to?(:handle_multipart_body, true)
        request_body = handle_multipart_body(request_headers, request_body)
      end

      request_metadata[:request_method] = method
      request_metadata[:request_path] = path
      request_metadata[:request_body] = request_body.empty? ? nil : request_body.force_encoding("UTF-8")
      request_metadata[:request_headers] = request_headers
      request_metadata[:request_query_parameters] = query_hash
      request_metadata[:request_content_type] = request_content_type
      request_metadata[:response_status] = status
      request_metadata[:response_status_text] = Rack::Utils::HTTP_STATUS_CODES[status]
      request_metadata[:response_body] = record_response_body(response_content_type, response_body)
      request_metadata[:response_headers] = response_headers
      request_metadata[:response_content_type] = response_content_type
      request_metadata[:curl] = Curl.new(method, path, request_body, request_headers)

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata
    end

    def query_hash
      Rack::Utils.parse_nested_query(query_string)
    end

    def headers(method, path, params, request_headers)
      request_headers || {}
    end

    def record_response_body(response_content_type, response_body)
      return nil if response_body.empty?

      formatter = RspecApiDocumentation.configuration.response_body_formatter
      formatter.call(response_content_type, response_body)
    end

    def clean_out_uploaded_data(params, request_body)
      params.each do |value|
        if [Hash, Array].member? value.class
          request_body = if value.respond_to?(:has_key?) && value.has_key?(:tempfile)
                           data = value[:tempfile].read
                           request_body.gsub(data, "[uploaded data]")
                         else
                           clean_out_uploaded_data(value, request_body)
                         end
        end
      end
      request_body
    end
  end
end
