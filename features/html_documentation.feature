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
    And   the file "docs/index.html" should contain HTML:
      """
      <h2>Greetings</h2>

      <ul>
          <li>
            <a href="greetings/greeting_your_favorite_gem.html">Greeting your favorite gem</a>
          </li>
      </ul>
      """

  Scenario: Example HTML documentation includes the parameters
    Then  the file "docs/greetings/greeting_your_favorite_gem.html" should contain HTML:
      """
      <h3>Parameters</h3>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <th>
              <span class="name">target</span>
            </th>
            <td>
              <span class="description">The thing you want to greet</span>
            </td>
          </tr>
        </tbody>
      </table>
      """

  Scenario: Example HTML documentation includes the request information
    Then  the file "docs/greetings/greeting_your_favorite_gem.html" should contain HTML:
      """
      <h3>Request</h3>
      <h4>Headers</h4>
      <pre class="headers">Host: example.org
      Cookie: </pre>
      <h4>Route</h4>
      <pre class="request highlight">GET /greetings?target=rspec_api_documentation</pre>
      <h4>Query Parameters</h4>
      <pre class="request highlight">target: rspec_api_documentation</pre>
      """

  Scenario: Example HTML documentation includes the response information
    Then  the file "docs/greetings/greeting_your_favorite_gem.html" should contain HTML:
      """
      <h3>Response</h3>
      <h4>Headers</h4>
      <pre class="headers">Content-Type: application/json
      Content-Length: 35</pre>
      <h4>Status</h4>
      <pre class="response_status">200 OK</pre>
      <h4>Body</h4>
      <pre class="response highlight">{
      &quot;hello&quot;: &quot;rspec_api_documentation&quot;
      }</pre>
      """
