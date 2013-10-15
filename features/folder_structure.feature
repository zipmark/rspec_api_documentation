Feature: Folder Structure
  Background:
    Given a file named "app.rb" with:
      """
      class App
        def self.call(env)
          [200, {}, ["hello"]]
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

      resource "Namespace::Greetings" do
        get "/greetings" do
          example_request "Greeting your favorite gem" do
            expect(status).to eq(200)
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Folder structure does not contain ::
    When  I open the index
    And   I navigate to "Greeting your favorite gem"

    Then  I should see the route is "GET /greetings"
