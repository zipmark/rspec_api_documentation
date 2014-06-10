module RspecApiDocumentation
  class TestServer < Struct.new(:example)
    include Headers

    delegate :metadata, :to => :example

    attr_reader :request_method, :request_headers, :request_body

    def call(env)
      input = env["rack.input"]
      input.rewind

      @request_method = env["REQUEST_METHOD"]
      @request_headers = env_to_headers(env)
      @request_body = input.read

      request_metadata = {}

      request_metadata[:request_method] = @request_method
      request_metadata[:request_path] = env["PATH_INFO"]
      request_metadata[:request_body] = @request_body
      request_metadata[:request_headers] = @request_headers

      metadata[:requests] ||= []
      metadata[:requests] << request_metadata

      return [200, {}, [""]]
    end
  end
end
