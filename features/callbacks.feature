Feature: Document callbacks

  Background:
    Given a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = lambda do
          uri = URI.parse("http://example.net/callback")
          Net::HTTP.start(uri.host, uri.port) do |http|
            request = Net::HTTP::Post.new(uri.path)
            request.body = '{"message":"Something interesting happened!"}'
            request["Content-Type"] = "application/json"
            request["User-Agent"] = "InterestingThingApp"
            http.request request
          end
          [200, {}, []]
        end
      end

      resource "Interesting Thing" do
        callback "/interesting_thing" do
          let(:callback_url) { "http://example.net/callback" }

          trigger_callback do
            app.call
          end

          example "Receiving a callback when interesting things happen" do
            do_callback
            expect(request_method).to eq("POST")
            expect(request_headers["Content-Type"]).to eq("application/json")
            expect(request_headers["User-Agent"]).to eq("InterestingThingApp")
            expect(request_body).to eq('{"message":"Something interesting happened!"}')
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output helpful progress to the console
    Then  the output should contain:
      """
      Generating API Docs
        Interesting Thing
        /interesting_thing
          * Receiving a callback when interesting things happen
      """
    And   the output should contain "1 example, 0 failures"
    And   the exit status should be 0

  Scenario: Create an index of all API examples, including all resources
    When  I open the index
    Then  I should see the following resources:
      | Interesting Thing |

  Scenario: Example HTML documentation includes the request information
    When  I open the index
    And   I navigate to "Receiving a callback when interesting things happen"
    Then  I should see the route is "POST /callback"
    And   I should see the following request headers:
      | Content-Type | application/json    |
      | Accept       | */*                 |
      | User-Agent   | InterestingThingApp |
    And   I should see the following request body:
      """
      {"message":"Something interesting happened!"}
      """
