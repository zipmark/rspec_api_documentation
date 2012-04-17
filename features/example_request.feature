Feature: Example Request
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
      end

      resource "Example Request" do
        get "/" do
          example_request "Greeting your favorite gem" do
            status.should eq(201)
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output should have the correct error line
    Then the output should contain:
      """
      Failure/Error: status.should eq(201)
      """
    Then the output should not contain "dsl.rb"
    Then the output should contain:
      """
      rspec ./app_spec.rb:10 # Example Request GET / Greeting your favorite gem
      """
