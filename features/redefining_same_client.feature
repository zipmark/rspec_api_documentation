Feature: Redefining the client method to the same method
  Background:
    Given a file named "app.rb" with:
      """
      class App
        def self.call(env)
          [200, {}, ["Hello, world"]]
        end
      end
      """
    And a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = App
        config.client_method = :client
      end

      resource "Example Request" do
        get "/" do
          example_request "Trying out get" do
            expect(status).to eq(200)
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output should have the correct error line
    Then  the output should contain "1 example, 0 failures"
    And   the exit status should be 0
