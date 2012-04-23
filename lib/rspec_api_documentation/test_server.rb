module RspecApiDocumentation
  class TestServer < Struct.new(:context)
    include Headers
    include Syntax

    delegate :example, :last_request, :last_response, :to => :context
    delegate :metadata, :to => :example

    def call(env)
      input = env["rack.input"]
      input.rewind
      request_body = input.read

      headers = env_to_headers(env)

      request_metadata = {}

      request_metadata[:request_method] = env["REQUEST_METHOD"]
      request_metadata[:request_path] = env["PATH_INFO"]
      request_metadata[:request_body] = highlight_syntax(request_body, headers["Content-Type"], true)
      request_metadata[:request_headers] = format_headers(headers)

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata

      return [200, {}, [""]]
    end
  end
end
