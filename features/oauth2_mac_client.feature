Feature: Use OAuth2 MAC client as a test client
  Background:
    Given a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"
      require "rack/builder"
      require "rack/oauth2"

      RspecApiDocumentation.configure do |config|
        config.app = Rack::Builder.new do
          map "/oauth2/token" do
            app = lambda do |env|
              headers = {"Pragma"=>"no-cache", "Content-Type"=>"application/json", "Content-Length"=>"274", "Cache-Control"=>"no-store"}
              body = ["{\"mac_algorithm\":\"hmac-sha-256\",\"expires_in\":29,\"access_token\":\"HfIBIMe/hxNKSMogD33OJmLN+i9x3d2iM7WLzrN1RQvINOFz+QT8hiMiY+avbp2mc8IpzrxoupHyy0DeKuB05Q==\",\"token_type\":\"mac\",\"mac_key\":\"jb59zUztvDIC0AeaNZz+BptWvmFd4C41JyZS1DfWqKCkZTErxSMfkdjkePUcpE9/joqFt0ELyV/oIsFAf0V1ew==\"}"]
              [200, headers, body]
            end

            run app
          end

          map "/" do
            app = lambda do |env|
              if env["HTTP_AUTHORIZATION"].blank?
                return [401, {"Content-Type" => "text/plain"}, [""]]
              end

              request = Rack::Request.new(env)
              response = Rack::Response.new
              response["Content-Type"] = "text/plain"
              response.write("hello #{request.params["target"]}")
              response.finish
            end

            run app
          end
        end
      end

      resource "Greetings" do
        let(:client) { RspecApiDocumentation::OAuth2MACClient.new(self, {:identifier => "1", :secret => "secret"}) }

        get "/" do
          parameter :target, "The thing you want to greet"

          example "Greeting your favorite gem" do
            do_request :target => "rspec_api_documentation"

            response_headers["Content-Type"].should eq("text/plain")
            status.should eq(200)
            response_body.should eq('hello rspec_api_documentation')
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output should contain
    Then  the output should contain:
      """
      Generating API Docs
        Greetings
        GET /
          * Greeting your favorite gem
      """
    And   the output should contain "1 example, 0 failures"
    And   the exit status should be 0
