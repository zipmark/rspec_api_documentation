module RspecApiDocumentation
  class RackTestClient < ClientBase

    delegate :last_request, :last_response, :to => :rack_test_session
    private :last_request, :last_response

    def request_headers
      env_to_headers(last_request.env)
    end

    def response_headers
      last_response.headers
    end

    def query_string
      last_request.env["QUERY_STRING"]
    end

    def status
      last_response.status
    end

    def response_body
      last_response.body
    end

    def request_content_type
      last_request.content_type
    end

    def response_content_type
      last_response.content_type
    end

    protected

    def do_request(method, path, params, request_headers)
      rack_test_session.send(method, path, params, headers(method, path, params, request_headers))
    end

    def headers(*args)
      headers_to_env(super)
    end

    def handle_multipart_body(request_headers, request_body)
      parsed_parameters = Rack::Request.new({
        "CONTENT_TYPE" => request_headers["Content-Type"],
        "rack.input" => StringIO.new(request_body)
      }).params

      clean_out_uploaded_data(parsed_parameters,request_body)
    end

    private

    def rack_test_session
      @rack_test_session ||= Struct.new(:app) do
        begin
          require "rack/test"
          include Rack::Test::Methods
        rescue LoadError
          raise "#{self.class.name} requires Rack::Test >= 0.5.5. Please add it to your test dependencies."
        end
      end.new(app)
    end
  end
end
