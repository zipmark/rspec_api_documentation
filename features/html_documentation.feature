Feature: Generate HTML documentation from test examples

  Background:
    Given a file named "app.rb" with:
      """
      class App
        def self.call(env)
          request = Rack::Request.new(env)
          response = Rack::Response.new
          response["Content-Type"] = "application/json"
          response.write({ "hello" => request.params["target"] }.to_json)
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
        config.api_name = "Example API"
      end

      resource "Greetings" do
        get "/greetings" do
          parameter :target, "The thing you want to greet"

          example "Greeting your favorite gem" do
            do_request :target => "rspec_api_documentation"

            response_headers["Content-Type"].should eq("application/json")
            status.should eq(200)
            response_body.should eq('{"hello":"rspec_api_documentation"}')
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
      """
    And   the output should contain "1 example, 0 failures"
    And   the exit status should be 0

  Scenario: Create an index of all API examples, including all resources
    When  I open the index
    Then  I should see the following resources:
      | Greetings |
    And   I should see the api name "Example API"

  Scenario: Example HTML documentation includes the parameters
    When  I open the index
    And   I navigate to "Greeting your favorite gem"
    Then  I should see the following parameters:
      | name   | description                 |
      | target | The thing you want to greet |

  Scenario: Example HTML documentation includes the request information
    When  I open the index
    And   I navigate to "Greeting your favorite gem"
    Then  I should see the route is "GET /greetings?target=rspec_api_documentation"
    And   I should see the following request headers:
      | Host   | example.org |
      | Cookie |             |
    And   I should see the following query parameters:
      | target | rspec_api_documentation |

  Scenario: Example HTML documentation includes the response information
    When  I open the index
    And   I navigate to "Greeting your favorite gem"
    Then  I should see the response status is "200 OK"
    And   I should see the following response headers:
      | Content-Type   | application/json |
      | Content-Length | 35               |
    And   I should see the following response body:
      """
      {"hello":"rspec_api_documentation"}
      """
