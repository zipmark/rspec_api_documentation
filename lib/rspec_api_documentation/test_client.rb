require "coderay"

module RspecApiDocumentation
  class TestClient < Struct.new(:context, :options)
    delegate :example, :app, :to => :context
    delegate :metadata, :to => :example
    delegate :last_request, :last_response, :to => :rack_test_session
    private :last_request, :last_response

    def rack_test_session
      @rack_test_session ||= Struct.new(:app) do
        begin
          include Rack::Test::Methods
        rescue LoadError
          raise "#{self.class.name} requires Rack::Test >= 0.5.5. Please add it to your test dependencies."
        end
      end.new(app)
    end

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

    def last_request_headers
      env_to_headers(last_request.env)
    end

    def last_response_headers
      last_response.headers
    end

    def last_query_string
      last_request.env["QUERY_STRING"]
    end

    def last_query_hash
      strings = last_query_string.split("&")
      arrays = strings.map do |segment|
        segment.split("=")
      end
      Hash[arrays]
    end

    def headers(method, action, params)
      if options && options[:headers]
        options[:headers]
      else
        {}
      end
    end

    def status
      last_response.status
    end

    def response_body
      last_response.body
    end

    private
    def process(method, action, params = {})
      rack_test_session.send(method, action, params, headers(method, action, params))

      document_example(method, action, params)
    end

    def document_example(method, action, params)
      return unless metadata[:document]

      input = last_request.env["rack.input"]
      input.rewind
      request_body = input.read

      request_metadata = {}

      request_metadata[:request_method] = method.to_s.upcase
      request_metadata[:request_path] = action
      request_metadata[:request_body] = highlight_syntax(request_body, last_request.content_type, true)
      request_metadata[:request_headers] = format_headers(last_request_headers)
      request_metadata[:request_query_parameters] = format_query_hash(last_query_hash)
      request_metadata[:response_status] = last_response.status
      request_metadata[:response_status_text] = Rack::Utils::HTTP_STATUS_CODES[last_response.status]
      request_metadata[:response_body] = highlight_syntax(response_body, last_response_headers['Content-Type'])
      request_metadata[:response_headers] = format_headers(last_response_headers)
      request_metadata[:curl] = Curl.new(method.to_s, action, request_body, last_request_headers)

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata
    end

    def env_to_headers(env)
      headers = {}
      env.each do |key, value|
        # HTTP_ACCEPT_CHARSET => Accept-Charset
        if key =~ /^(HTTP_|CONTENT_TYPE)/
          header = key.gsub(/^HTTP_/, '').titleize.split.join("-")
          headers[header] = value
        end
      end
      headers
    end

    def format_headers(headers)
      headers.map do |key, value|
        "#{key}: #{value}"
      end.join("\n")
    end

    def format_query_hash(query_hash)
      return if query_hash.blank?
      query_hash.map do |key, value|
        "#{key}: #{CGI.unescape(value)}"
      end.join("\n")
    end

    def highlight_syntax(body, content_type, is_query_string = false)
      return if body.blank?
      begin
        case content_type
          when /json/
            CodeRay.scan(JSON.pretty_generate(JSON.parse(body)), :json).div
          when /html/
            CodeRay.scan(body, :html).div
          when /javascript/
            CodeRay.scan(body, :java_script).div
          when /xml/
            CodeRay.scan(body, :xml).div
          else
            body = prettify_request_body(body) if is_query_string
            "<pre>#{body}</pre>"
        end
      rescue
        "<pre>#{body}</pre>"
      end
    end

    def prettify_request_body(string)
      return if string.blank?
      CGI.unescape(string.split("&").join("\n"))
    end
  end
end
