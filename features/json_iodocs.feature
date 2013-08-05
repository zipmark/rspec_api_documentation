Feature: Json Iodocs
  In order to serve the docs from my API
  As Zipmark
  I want to generate text files for each of my resources containing their combined docs

  Background:
    Given a file named "app.rb" with:
      """
      class App
        def self.call(env)
          request = Rack::Request.new(env)
          response = Rack::Response.new
          response["Content-Type"] = "text/plain"
          response.write("Hello, #{request.params["target"]}!")
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
        config.api_name = "app"
        config.format = :json_iodocs
      end

      resource "Greetings" do
        get "/greetings" do
          parameter :target, "The thing you want to greet"

          example "Greeting your favorite gem" do
            do_request :target => "rspec_api_documentation"

            response_headers["Content-Type"].should eq("text/plain")
            status.should eq(200)
            response_body.should eq('Hello, rspec_api_documentation!')
          end

          example "Greeting your favorite developers of your favorite gem" do
            do_request :target => "Sam & Eric"

            response_headers["Content-Type"].should eq("text/plain")
            status.should eq(200)
            response_body.should eq('Hello, Sam & Eric!')
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output helpful progress to the console
    Then  the output should contain:
      """
      Generating API Docs
        Greetings
        GET /greetings
          * Greeting your favorite gem
          * Greeting your favorite developers of your favorite gem
      """
    And   the output should contain "2 examples, 0 failures"
    And   the exit status should be 0

  Scenario: File should look like we expect
    Then the file "doc/api/app.json" should contain JSON exactly like:
    """
      {
        "endpoints": [
          {
            "name": "Greetings",
            "methods": [
              {
                "MethodName": "Greeting your favorite developers of your favorite gem",
                "Synopsis": null,
                "HTTPMethod": "GET",
                "URI": "/greetings?target=Sam+%26+Eric",
                "RequiresOAuth": "N",
                "parameters": [
                  {
                    "Name": "target",
                    "Description": "The thing you want to greet",
                    "Default": "",
                    "Required": "N"
                  }
                ]
              },
              {
                "MethodName": "Greeting your favorite gem",
                "Synopsis": null,
                "HTTPMethod": "GET",
                "URI": "/greetings?target=rspec_api_documentation",
                "RequiresOAuth": "N",
                "parameters": [
                  {
                    "Name": "target",
                    "Description": "The thing you want to greet",
                    "Default": "",
                    "Required": "N"
                  }
                ]
              }
            ]
          }
        ]
      }
    """

