Feature: Combined text
  In order to serve the docs from my API
  As Zipmark
  I want to generate text files for each of my resources containing their combined docs

  Background:
    Given a file named "app.rb" with:
      """
      class App
        def self.call(env)
          request = Rack::Request.new(env)
          response = Rack::Response.new
          response["Content-Type"] = "text/plain"
          response.write("Hello, #{request.params["target"]}!")
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
        config.format = :combined_text
      end

      resource "Greetings" do
        get "/greetings" do
          parameter :target, "The thing you want to greet"

          example "Greeting your favorite gem" do
            do_request :target => "rspec_api_documentation"

            expect(response_headers["Content-Type"]).to eq("text/plain")
            expect(status).to eq(200)
            expect(response_body).to eq('Hello, rspec_api_documentation!')
          end

          example "Greeting your favorite developers of your favorite gem" do
            do_request :target => "Sam & Eric"

            expect(response_headers["Content-Type"]).to eq("text/plain")
            expect(status).to eq(200)
            expect(response_body).to eq('Hello, Sam & Eric!')
          end

          example "Multiple Requests" do
            do_request :target => "Sam"
            do_request :target => "Eric"
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
          * Greeting your favorite developers of your favorite gem
      """
    And   the output should contain "3 examples, 0 failures"
    And   the exit status should be 0

  Scenario: File should look like we expect
    Then the file "doc/api/greetings/index.txt" should contain exactly:
    """
    Greeting your favorite gem
    --------------------------

    Parameters:
      * target - The thing you want to greet

    Request:
      GET /greetings?target=rspec_api_documentation
      Cookie: 
      Host: example.org

      target=rspec_api_documentation

    Response:
      Status: 200 OK
      Content-Length: 31
      Content-Type: text/plain

      Hello, rspec_api_documentation!


    Greeting your favorite developers of your favorite gem
    ------------------------------------------------------

    Parameters:
      * target - The thing you want to greet

    Request:
      GET /greetings?target=Sam+%26+Eric
      Cookie: 
      Host: example.org

      target=Sam & Eric

    Response:
      Status: 200 OK
      Content-Length: 18
      Content-Type: text/plain

      Hello, Sam & Eric!


    Multiple Requests
    -----------------

    Parameters:
      * target - The thing you want to greet

    Request:
      GET /greetings?target=Sam
      Cookie: 
      Host: example.org

      target=Sam

    Response:
      Status: 200 OK
      Content-Length: 11
      Content-Type: text/plain

      Hello, Sam!

    Request:
      GET /greetings?target=Eric
      Cookie: 
      Host: example.org

      target=Eric

    Response:
      Status: 200 OK
      Content-Length: 12
      Content-Type: text/plain

      Hello, Eric!
    """

