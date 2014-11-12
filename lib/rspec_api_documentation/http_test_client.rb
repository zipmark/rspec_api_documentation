begin
  require 'faraday'
rescue LoadError
  raise "Faraday needs to be installed before using the HttpTestClient"
end

Faraday::Request.register_middleware :request_saver => lambda { RspecApiDocumentation::RequestSaver }

module RspecApiDocumentation
  class RequestSaver < Faraday::Middleware
    attr_reader :client

    def initialize(app, client)
      super(app)
      @client = client
    end

    def call(env)
      client.last_request = env

      @app.call(env).on_complete do |env|
        client.last_response = env
      end
    end
  end

  class HttpTestClient < ClientBase
    attr_reader :last_response, :last_request

    LastRequest = Struct.new(:url, :method, :request_headers, :body)

    def request_headers
      env_to_headers(last_request.request_headers)
    end

    def response_headers
      last_response.response_headers
    end

    def query_string
      last_request.url.query
    end

    def status
      last_response.status
    end

    def response_body
      last_response.body
    end

    def request_content_type
      last_request.request_headers["CONTENT_TYPE"]
    end

    def response_content_type
      last_response.request_headers["CONTENT_TYPE"]
    end

    def do_request(method, path, params, request_headers)
      http_test_session.send(method, path, params, headers(method, path, params, request_headers))
    end

    def last_request=(env)
      @last_request = LastRequest.new(env.url, env.method, env.request_headers, env.body)
    end

    def last_response=(env)
      @last_response = env
    end

    protected

    def headers(*args)
      headers_to_env(super)
    end

    def handle_multipart_body(request_headers, request_body)
      parsed_parameters = Rack::Request.new({
        "CONTENT_TYPE" => request_headers["Content-Type"],
        "rack.input" => StringIO.new(request_body)
      }).params

      clean_out_uploaded_data(parsed_parameters, request_body)
    end

    def read_request_body
      if [:post, :put].include?(last_request.method)
        last_request.body || ""
      else
        ""
      end
    end

    private

    def http_test_session
      ::Faraday.new(:url => options[:host]) do |faraday|
        faraday.request :url_encoded            # form-encode POST params
        faraday.request :request_saver, self    # save the request and response
        faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end
  end
end
