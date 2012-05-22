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
      rack_test_session.send(method, path, params, headers(request_headers))
    end

    def headers(*args)
      super.inject({}) do |hsh, (k, v)|
        new_key = k.upcase.gsub("-", "_")
        new_key = "HTTP_#{new_key}" unless new_key == "CONTENT_TYPE"
        hsh[new_key] = v
        hsh
      end
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
