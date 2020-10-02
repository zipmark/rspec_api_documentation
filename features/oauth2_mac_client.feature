Feature: Use OAuth2 MAC client as a test client
  Background:
    Given a file named "app_spec.rb" with:
      """
      require "webmock/rspec"
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"
      require "rack/builder"

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

           map "/multiple" do
             app = lambda do |env|
               if env["HTTP_AUTHORIZATION"].blank?
               return [401, {"Content-Type" => "text/plain"}, [""]]
             end

             request = Rack::Request.new(env)
             response = Rack::Response.new
             response["Content-Type"] = "text/plain"
             response.write("hello #{request.params["targets"].join(", ")}")
             response.finish
            end

            run app
          end

           map "/multiple_nested" do
             app = lambda do |env|
               if env["HTTP_AUTHORIZATION"].blank?
               return [401, {"Content-Type" => "text/plain"}, [""]]
             end

             request = Rack::Request.new(env)
             response = Rack::Response.new
             response["Content-Type"] = "text/plain"
             response.write("hello #{request.params["targets"].sort.map {|company, products| company.to_s + ' with ' + products.join(' and ')}.join(", ")}")
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

            expect(response_headers["Content-Type"]).to eq("text/plain")
            expect(status).to eq(200)
            expect(response_body).to eq('hello rspec_api_documentation')
          end
        end

        get "/multiple" do
          parameter :targets, "The people you want to greet"

          let(:targets) { ["eric", "sam"] }

          example "Greeting your favorite people" do
            do_request

            expect(response_headers["Content-Type"]).to eq("text/plain")
            expect(status).to eq(200)
            expect(response_body).to eq("hello eric, sam")
          end
        end

        get "/multiple_nested" do
          parameter :targets, "The companies you want to greet"

          let(:targets) { { "apple" => ['mac', 'ios'], "google" => ['search', 'mail']} }

          example "Greeting your favorite companies" do
            do_request

            expect(response_headers["Content-Type"]).to eq("text/plain")
            expect(status).to eq(200)
            expect(response_body).to eq("hello apple with mac and ios, google with search and mail")
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
        GET /multiple
          * Greeting your favorite people
        GET /multiple_nested
          * Greeting your favorite companies
      """
    And   the output should contain "3 examples, 0 failures"
    And   the exit status should be 0
