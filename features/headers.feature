Feature: Specifying request headers

  Background:
    Given a file named "app.rb" with:
      """
      class App
        def self.call(env)
          if env["HTTP_ACCEPT"] == "foo"
            [200, {}, ["foo"]]
          else
            [406, {}, ["unknown content type"]]
          end
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

      resource "FooBars" do
        get "/foobar" do
          header "Accept", "foo"

          example "Getting Foo" do
            do_request
            expect(response_body).to eq("foo")
          end
        end
      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Sending headers along with the request
    Then  the output should not contain "unknown content type"
