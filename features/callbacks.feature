Feature: Document callbacks

  Background:
    Given a file named "app.rb" with:
      """
      require "sinatra/base"

      class App < Sinatra::Base
        post "/interesting_thing" do
          uri = URI.parse("http://example.net/callback")
          Net::HTTP.start(uri.host, uri.port) do |http|
            request = Net::HTTP::Post.new(uri.path)
            request.body = '{"message":"Something interesting happened!"}'
            request.add_field("Content-Type", "application/json")
            http.request request
          end
          200
        end
      end
      """
    And   a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = App
      end

      resource "Interesting Thing" do
        callback "/interesting_thing" do
          let(:callback_url) { "http://example.net/callback" }

          trigger_callback do
            post "/interesting_thing"
          end

          example "Receiving a callback when interesting things happen" do
            do_callback
          end
        end
      end
      """

    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

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
      """
      Content-Type: application/json
      Accept: */*
      User-Agent: Ruby
      """
    And   I should see the following request body:
      """
      {
        "message": "Something interesting happened!"
      }
      """
