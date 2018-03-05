Feature: Postman

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
        config.api_explanation = "desc"
        config.format = :postman
        config.io_docs_protocol = "https"
      end

      resource "Greetings" do
        explanation "Greetings API methods"
        header "Content-Type", "application/json"

        get "/greetings" do
          parameter :target, "The thing you want to greet"
          parameter :type, "foo"

          example "Greeting your favorite gem" do
            do_request({:target => "rspec_api_documentation", :type => "foo"})

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
    Then the file "doc/api/app.postman_collection.json" should contain JSON exactly like:
    """
      {
        "info": {
          "name": "app",
          "description": "desc",
          "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
        },
        "item": [
          {
            "name": "Greetings",
            "description": "Greetings API methods",
            "item": [
              {
                "name": "Greeting your favorite developers of your favorite gem",
                "request": {
                  "method": "GET",
                  "header": [
                    {
                      "key": "Content-Type",
                      "value": "application/json"
                    }
                   ],
                  "body": {},
                  "url": {
                    "host": [
                      "{{application_url}}"
                    ],
                    "path": [
                      "greetings"
                    ],
                    "query" : [
                      {
                        "key": "target",
                        "value": "",
                        "equals": true,
                        "description": "The thing you want to greet",
                        "disabled": true
                      }
                    ],
                    "variable": []
                  },
                  "description": "\n * `target`: The thing you want to greet\n * `type`: foo"
                },
                "response": []
              },
              {
                "name": "Greeting your favorite gem",
                "request": {
                  "method": "GET",
                  "header": [
                    {
                      "key": "Content-Type",
                      "value": "application/json"
                    }
                   ],
                  "body": {},
                  "url": {
                    "host": [
                      "{{application_url}}"
                    ],
                    "path": [
                      "greetings"
                    ],
                    "query" : [
                      {
                        "key": "target",
                        "value": "",
                        "equals": true,
                        "description": "The thing you want to greet",
                        "disabled": true
                      },
                      {
                        "key": "type",
                        "value": "",
                        "equals": true,
                        "description": "foo",
                        "disabled": true
                      }
                    ],
                    "variable": []
                  },
                  "description": "\n * `target`: The thing you want to greet\n * `type`: foo"
                },
                "response": []
              }
            ]
          }
        ]
      }
    """


