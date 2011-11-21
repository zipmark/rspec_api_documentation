module RspecApiDocumentation
  class TestServer < Struct.new(:session)
    delegate :example, :last_request, :last_response, :to => :session
    delegate :metadata, :to => :example

    def call(env)
      env["rack.input"].rewind

      metadata[:public] = (metadata[:document] == :public)
      metadata[:method] = env["REQUEST_METHOD"]
      metadata[:route] = env["PATH_INFO"]
      metadata[:request_body] = prettify_json(env["rack.input"].read)
      metadata[:request_headers] = headers(env)

      return [200, {}, [""]]
    end

    private

    def headers(env)
      env.
        select do |k, v|
          k =~ /^(HTTP_|CONTENT_TYPE)/
        end.
        map do |key, value|
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
