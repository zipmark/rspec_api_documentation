module RspecApiDocumentation
  class TestClient < Struct.new(:session)
    attr_accessor :user

    delegate :example, :last_response, :last_request, :to => :session
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

    def sign_in(user)
      @user = user
    end

    def last_headers
      session.last_request.env.select do |k, v|
        k =~ /^(HTTP_|CONTENT_TYPE)/
      end
    end

    def headers(method, action, params)
      {}
    end

    private
    def process(method, action, params = {})
      session.send(method, action, params, headers(method, action, params))

      document_example(method, action, params)
    end

    def document_example(method, action, params)
      return unless metadata[:document]

      input = last_request.env["rack.input"]
      input.rewind
      request_body = input.read

      metadata[:public] = (metadata[:document] == :public)
      metadata[:method] = method.to_s.upcase
      metadata[:route] = action
      metadata[:request_body] = prettify_json(request_body)
      metadata[:request_headers] = format_headers(last_headers)
      metadata[:response_status] = last_response.status
      metadata[:response_status_text] = Rack::Utils::HTTP_STATUS_CODES[last_response.status]
      metadata[:response_body] = prettify_json(last_response.body)
      metadata[:response_headers] = format_headers(last_response.headers)
    end

    def format_headers(headers)
      headers.map do |key, value|
        # HTTP_ACCEPT_CHARSET => Accept-Charset
        formatted_key = key.gsub(/^HTTP_/, '').titleize.split.join("-")
        "#{formatted_key}: #{value}"
      end.join("\n")
    end

    def prettify_json(json)
      begin
        JSON.pretty_generate(JSON.parse(json))
      rescue
        nil
      end
    end
  end
end
