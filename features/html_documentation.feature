Feature: Generate HTML documentation from test examples

  Background:
    Given a file named "app.rb" with:
      """
      require "sinatra/base"

      class App < Sinatra::Base
        before do
          content_type :json
        end

        get "/greetings" do
          if target = params["target"]
            { "hello" => params["target"] }.to_json
          else
            422
          end
        end
      end
      """
    And   a file named "app_spec.rb" with:
      """
      require "active_support/inflector"
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = App
      end

      resource "Greetings" do
        get "/greetings" do
          parameter :target, "The thing you want to greet"

          example "Greeting your favorite gem" do
            do_request :target => "rspec_api_documentation"

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

  Scenario: Create an index of all API examples, including all resources and examples
    Then  the file "docs/index.html" should contain "<h2>Greetings</h2>"
    And   the file "docs/index.html" should contain:
      """
      <a href="greetings/greeting_your_favorite_gem.html">Greeting your favorite gem</a>
      """

  Scenario: Create a file for each API example
    Then  the file "docs/greetings/greeting_your_favorite_gem.html" should contain "<h2>Greeting your favorite gem</h2>"
