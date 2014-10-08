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

  Scenario: Output should have the correct error line
    Given a file named "app_spec.rb" with:
    """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = App
      end

      resource "Example Request" do
        get "/" do
          example_request "Greeting your favorite gem" do
            expect(status).to eq(201)
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`
    Then the output should contain "expected: 201"
    Then the output should not contain "endpoint.rb"
    Then the output should contain:
      """
      rspec ./app_spec.rb:10 # Example Request GET / Greeting your favorite gem
      """

  Scenario: should work with RSpec monkey patching disabled
    When a file named "app_spec.rb" with:
    """
      require "rspec_api_documentation/dsl"

      RSpec.configure do |config|
        config.disable_monkey_patching!
      end

      RspecApiDocumentation.configure do |config|
        config.app = App
      end

      RSpec.resource "Example Request" do
        get "/" do
          example_request "Greeting your favorite gem" do
            expect(status).to eq(200)
          end
        end
      end
      """
    Then I successfully run `rspec app_spec.rb --require ./app.rb`
