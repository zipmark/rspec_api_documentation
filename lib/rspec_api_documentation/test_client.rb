require "coderay"

module RspecApiDocumentation
  class TestClient < Struct.new(:session, :options)
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
      headers = session.last_request.env.select do |k, v|
        k =~ /^(HTTP_|CONTENT_TYPE)/
      end
      Hash[headers]
    end

    def last_query_string
      session.last_request.env["QUERY_STRING"]
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

      request_metadata = {}

      request_metadata[:method] = method.to_s.upcase
      request_metadata[:route] = action
      if is_json?(request_body)
        request_metadata[:request_body] = prettify_json(request_body)
      else
        request_metadata[:request_body] = prettify_request_body(request_body)
      end
      request_metadata[:request_headers] = format_headers(last_headers)
      request_metadata[:request_query_parameters] = format_query_hash(last_query_hash)
      request_metadata[:response_status] = last_response.status
      request_metadata[:response_status_text] = Rack::Utils::HTTP_STATUS_CODES[last_response.status]
      request_metadata[:response_body] = formatted_response_body(last_response.body, last_response.headers['Content-Type'])
      request_metadata[:response_headers] = format_headers(last_response.headers)
      request_metadata[:curl] = Curl.new(method.to_s, action, request_body, last_headers)

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata
    end

    def format_headers(headers)
      headers.map do |key, value|
        # HTTP_ACCEPT_CHARSET => Accept-Charset
        formatted_key = key.gsub(/^HTTP_/, '').titleize.split.join("-")
        "#{formatted_key}: #{value}"
      end.join("\n")
    end

    def format_query_hash(query_hash)
      return if query_hash.blank?
      query_hash.map do |key, value|
        "#{key}: #{CGI.unescape(value)}"
      end.join("\n")
    end

    def prettify_json(json)
      begin
        JSON.pretty_generate(JSON.parse(json))
      rescue
        nil
      end
    end

    def formatted_response_body(body, content_type)
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
          body
      end
    end

    def prettify_request_body(string)
      return if string.blank?
      CGI.unescape(string.split("&").join("\n"))
    end

    def is_json?(string)
      begin
        JSON.parse(string)
      rescue
        false
      end
    end
  end
end
