require "coderay"

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

    def content_type
      last_request.content_type
    end

    protected

    def do_request(method, path, params)
      rack_test_session.send(method, path, params, headers(method, path, params))
    end

    private

    def rack_test_session
      @rack_test_session ||= Struct.new(:app) do
        begin
          include Rack::Test::Methods
        rescue LoadError
          raise "#{self.class.name} requires Rack::Test >= 0.5.5. Please add it to your test dependencies."
        end
      end.new(app)
    end
  end
end
