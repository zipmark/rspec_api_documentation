module RspecApiDocumentation
  class TestClient < Struct.new(:session)
    attr_accessor :user
    attr_reader :last_headers

    delegate :example, :last_response, :to => :session
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

    def set_headers(method, action, params = {})
      session.request.env.merge!(headers(method, action, params))
    end

    def sign_in(user)
      @user = user
    end

    private
    def process(method, action, params = {})
      session.send(method, action, params, headers(method, action, params))

      document_example(method, action, params)
    end

    def document_example(method, action, params)
      return unless metadata[:document]

      metadata[:public] = (metadata[:document] == :public)
      metadata[:method] = method.to_s.upcase
      metadata[:route] = action
      metadata[:parameters] = nil
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
      if json.strip.blank?
        nil
      else
        JSON.pretty_generate(JSON.parse(json))
      end
    end

    def headers(method, action, params)
      @last_headers = {}
    end
  end
end
