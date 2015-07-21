Feature: Combined text
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
        config.format = :combined_json
        config.request_headers_to_include = %w[Host]
        config.response_headers_to_include = %w[Content-Type]
      end

      resource "Greetings" do
        explanation "Welcome to the party"

        get "/greetings" do
          parameter :target, "The thing you want to greet"

          example "Greeting your favorite gem" do
            do_request :target => "rspec_api_documentation"

            expect(response_headers["Content-Type"]).to eq("text/plain")
            expect(status).to eq(200)
            expect(response_body).to eq('Hello, rspec_api_documentation!')
          end

          example "Greeting your favorite developers of your favorite gem" do
            do_request :target => "Sam & Eric"

            expect(response_headers["Content-Type"]).to eq("text/plain")
            expect(status).to eq(200)
            expect(response_body).to eq('Hello, Sam & Eric!')
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
    Then the file "doc/api/combined.json" should contain JSON exactly like:
    """
    [
      {
        "resource": "Greetings",
        "resource_explanation": "Welcome to the party",
        "http_method": "GET",
        "route": "/greetings",
        "description": "Greeting your favorite gem",
        "explanation": null,
        "parameters": [
          {
            "name": "target",
            "description": "The thing you want to greet"
          }
        ],
        "response_fields": [],
        "requests": [
          {
            "request_method": "GET",
            "request_path": "/greetings?target=rspec_api_documentation",
            "request_body": null,
            "request_headers": {
              "Host": "example.org"
            },
            "request_query_parameters": {
              "target": "rspec_api_documentation"
            },
            "request_content_type": null,
            "response_status": 200,
            "response_status_text": "OK",
            "response_body": "Hello, rspec_api_documentation!",
            "response_headers": {
              "Content-Type": "text/plain"
            },
            "response_content_type": "text/plain",
            "curl": null
          }
        ]
      },
      {
        "resource": "Greetings",
        "resource_explanation": "Welcome to the party",
        "http_method": "GET",
        "route": "/greetings",
        "description": "Greeting your favorite developers of your favorite gem",
        "explanation": null,
        "parameters": [
          {
            "name": "target",
            "description": "The thing you want to greet"
          }
        ],
        "response_fields": [],
        "requests": [
          {
            "request_method": "GET",
            "request_path": "/greetings?target=Sam+%26+Eric",
            "request_body": null,
            "request_headers": {
              "Host": "example.org"
            },
            "request_query_parameters": {
              "target": "Sam & Eric"
            },
            "request_content_type": null,
            "response_status": 200,
            "response_status_text": "OK",
            "response_body": "Hello, Sam & Eric!",
            "response_headers": {
              "Content-Type": "text/plain"
            },
            "response_content_type": "text/plain",
            "curl": null
          }
        ]
      }
    ]
    """

