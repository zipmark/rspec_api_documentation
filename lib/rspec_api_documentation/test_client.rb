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
      headers = last_request.env.select do |k, v|
        k =~ /^(HTTP_|CONTENT_TYPE)/
      end
      Hash[headers]
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

    private
    def process(method, action, params = {})
      session.send(method, action, params, headers(method, action, params))

      document_example(method, action, params)
    end

    def document_example(method, action, params)
      return unless metadata[:document]
      action_parts = action.split("?")
      input = last_request.env["rack.input"]
      input.rewind
      request_body = input.read

      request_metadata = {}

      request_metadata[:method] = method
      request_metadata[:route] = action_parts[0]
      request_metadata[:query_string] = action_parts.length > 1 ? "?#{action_parts[1]}" : nil
      request_metadata[:request_body] = request_body.empty? ? nil : request_body
      request_metadata[:request_content_type] = last_request.content_type
      request_metadata[:response_content_type] = last_response.content_type
      request_metadata[:request_headers] = last_headers.map { |k, v| {:name => k.gsub(/^HTTP_/, '').titleize.split.join("-"), :value => v} }
      request_metadata[:request_query_parameters] =  last_query_hash.map { |k, v| { :name => k, :value => v } }
      request_metadata[:response_status] = last_response.status
      request_metadata[:response_body] = last_response.body
      request_metadata[:response_headers] = last_response.headers
      request_metadata[:curl] = Curl.new(method.to_s, action, request_body, last_headers)

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata
    end
  end
end
