Feature: cURL output
  Background:
    Given a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      class App
        def self.call(env)
          if env["HTTP_ACCEPT"] == "foo"
            [200, {}, ["foo"]]
          else
            [406, {}, ["unknown content type"]]
          end
        end
      end

      RspecApiDocumentation.configure do |config|
        config.app = App
        config.curl_host = "example.org"
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

  Scenario: Not filtering headers in cURL
    Given a file named "config.rb" with:
      """
      """
    When  I run `rspec app_spec.rb --require ./config.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the outputted docs should not filter out headers

  Scenario: Filtering out headers in cURL
    Given a file named "config.rb" with:
      """
      require "rspec_api_documentation"

      RspecApiDocumentation.configure do |config|
        config.curl_headers_to_filter = ["Host", "Cookie"]
      end
      """
    When  I run `rspec app_spec.rb --require ./config.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the outputted docs should filter out headers
