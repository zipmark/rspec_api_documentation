Feature: Generate Textile documentation from test examples

  Background:
    Given a file named "app.rb" with:
      """
      require 'sinatra'

      class App < Sinatra::Base
        get '/greetings' do
          content_type :json

          [200, { 'hello' => params[:target] }.to_json ]
        end

        get '/cucumbers' do
          content_type :json

          [200, { 'hello' => params[:target] }.to_json ]
        end
      end
      """
    And   a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = App
        config.api_name = "Example API"
        config.format = :textile
      end

      resource "Greetings" do
        get "/greetings" do
          parameter :target, "The thing you want to greet"
          required_parameters :target

          example "Greeting your favorite gem" do
            do_request :target => "rspec_api_documentation"

            response_headers["Content-Type"].should eq("application/json;charset=utf-8")
            status.should eq(200)
            response_body.should eq('{"hello":"rspec_api_documentation"}')
          end

          example "Greeting nothing" do
            do_request :target => ""

            response_headers["Content-Type"].should eq("application/json;charset=utf-8")
            status.should eq(200)
            response_body.should eq('{"hello":""}')
          end
        end
      end

      resource "Cucumbers" do
        get "/cucumbers" do
          parameter :target, "The thing in which you want to eat cucumbers"

          example "Eating cucumbers in a bowl" do
            do_request :target => "bowl"

            response_headers["Content-Type"].should eq("application/json;charset=utf-8")
            status.should eq(200)
            response_body.should eq('{"hello":"bowl"}')
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
          * Greeting nothing
        Cucumbers
        GET /cucumbers
          * Eating cucumbers in a bowl
      """
    And   the output should contain "3 examples, 0 failures"
    And   the exit status should be 0

  Scenario: Index file should look like we expect
    Then the file "docs/index.textile" should contain exactly:
    """
    h1. Example API

    h2. Cucumbers

    * Eating cucumbers in a bowl

    h2. Greetings

    * Greeting nothing
    * Greeting your favorite gem


    """

  Scenario: Example 'Greeting your favorite gem' file should look like we expect
    Then the file "docs/greetings/greeting_your_favorite_gem.textile" should contain exactly:
    """
    h1. Greetings API

    h2. Greeting your favorite gem

    h3. GET /greetings


    h3. Parameters

    Name : target  *- required -*
    Description : The thing you want to greet

    h3. Request

    h4. Headers

    <pre>Host: example.org
    Cookie: </pre>

    h4. Route

    <pre>GET /greetings?target=rspec_api_documentation</pre>

    h4. Query Parameters

    <pre>target: rspec_api_documentation</pre>



    h3. Response

    h4. Headers

    <pre>X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: application/json;charset=utf-8
    Content-Length: 35</pre>

    h4. Status

    <pre>200 OK</pre>

    h4. Body

    <pre>{"hello":"rspec_api_documentation"}</pre>



    """
