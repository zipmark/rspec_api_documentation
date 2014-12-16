Feature: Disable DSL features
  Background:
    Given a file named "app.rb" with:
      """
      class App
        def self.call(env)
          request = Rack::Request.new(env)
          response = Rack::Response.new
          response["Content-Type"] = "text/plain"
          response.write(request.params["status"])
          response.write(request.params["method"])
          response.finish
        end
      end
      """
    And   a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = App
        config.disable_dsl_status!
        config.disable_dsl_method!
      end

      resource "Orders" do
        get "/orders" do
          parameter :status, "Order status to search for"
          parameter :method, "Method of delivery to search for"

          example "Viewing all orders" do
            do_request :status => "pending"
            expect(response_status).to eq(200)
            expect(response_body).to eq("pending")
          end

          example "Checking the method" do
            do_request :method => "ground"
            expect(http_method).to eq(:get)
            expect(response_body).to eq("ground")
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output should have the correct error line
    Then  the output should contain "2 examples, 0 failures"
    And   the exit status should be 0
