module RspecApiDocumentation
  class TestServer < Struct.new(:context)
    include Headers

    delegate :example, :last_request, :last_response, :to => :context
    delegate :metadata, :to => :example

    def call(env)
      env["rack.input"].rewind

      request_metadata = {}

      request_metadata[:request_method] = env["REQUEST_METHOD"]
      request_metadata[:request_path] = env["PATH_INFO"]
      request_metadata[:request_body] = prettify_json(env["rack.input"].read)
      request_metadata[:request_headers] = format_headers(env_to_headers(env))

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata

      return [200, {}, [""]]
    end

    private

    def prettify_json(json)
      begin
        JSON.pretty_generate(JSON.parse(json))
      rescue
        nil
      end
    end
  end
end
