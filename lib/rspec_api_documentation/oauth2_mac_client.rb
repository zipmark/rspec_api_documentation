begin
  require "active_support/secure_random"
rescue LoadError
  # ActiveSupport::SecureRandom not provided in activesupport >= 3.2
end
begin
  require "webmock/rspec"
rescue LoadError
  raise "Webmock needs to be installed before using the OAuth2MACClient"
end
begin
  require "rack/oauth2"
rescue LoadError
  raise "Rack OAuth2 needs to be installed before using the OAuth2MACClient"
end

module RspecApiDocumentation
  class OAuth2MACClient < ClientBase
    include WebMock::API
    attr_accessor :last_response, :last_request
    private :last_response, :last_request

    def request_headers
      env_to_headers(last_request.env)
    end

    def response_headers
      if last_response.respond_to?(:headers)
        last_response.headers
      elsif last_response.respond_to?(:env) && last_response.env.respond_to?(:response_headers)
        last_response.env.response_headers
      else
        {}
      end
    end

    def query_string
      last_request.env["QUERY_STRING"]
    end

    def status
      if last_response.respond_to?(:status)
        last_response.status
      else
        last_response.env.status if last_response.respond_to?(:env)
      end
    end

    def response_body
      last_response.body
    end

    def request_content_type
      last_request.content_type
    end

    def response_content_type
      if last_response.respond_to?(:content_type)
        last_response.content_type
      elsif last_response.respond_to?(:headers)
        last_response.headers['Content-Type'] || last_response.headers['content-type']
      else
        nil
      end
    end

    protected

    def do_request(method, path, params, request_headers)
      self.last_response = access_token.send(method, "http://example.com#{path}", :body => params, :header => headers(method, path, params, request_headers))
    end

    class ProxyApp < Struct.new(:client, :app)
      def call(env)
        env["QUERY_STRING"] = query_string_hack(env)
        client.last_request = Struct.new(:env, :content_type).new(env, env["CONTENT_TYPE"])
        app.call(env.merge("SCRIPT_NAME" => ""))
      end

    private
      def query_string_hack(env)
        env["QUERY_STRING"].gsub('%5B', '[').gsub('%5D', ']').gsub(/\[\d+/) { |s| "#{$1}[" }
      end
    end

    def access_token
      @access_token ||= begin
                          app = ProxyApp.new(self, context.app)
                          stub_request(:any, %r{http://example\.com}).to_rack(app)

                          # Create a Bearer access token as MAC is no longer supported
                          access_token = Rack::OAuth2::AccessToken::Bearer.new(
                            :access_token => options[:identifier] || "1"
                          )

                          access_token
                        end
    end
  end
end
