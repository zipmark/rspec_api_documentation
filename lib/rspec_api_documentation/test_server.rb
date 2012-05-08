module RspecApiDocumentation
  class TestServer < Struct.new(:session)
    delegate :example, :last_request, :last_response, :to => :session
    delegate :metadata, :to => :example

    def call(env)
      env["rack.input"].rewind

      request_metadata = {}

      request_metadata[:method] = env["REQUEST_METHOD"]
      request_metadata[:route] = env["PATH_INFO"]
      request_metadata[:request_body] = prettify_json(env["rack.input"].read)
      request_metadata[:request_headers] = headers(env)

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata

      return [200, {}, [""]]
    end

    private

    def headers(env)
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

    def prettify_json(json)
      begin
        JSON.pretty_generate(JSON.parse(json))
      rescue
        nil
      end
    end
  end
end
