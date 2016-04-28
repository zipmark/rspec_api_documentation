Feature: Generate Slate documentation from test examples

  Background:
    Given a file named "app.rb" with:
      """
      require 'sinatra'

      class App < Sinatra::Base
        get '/orders' do
          content_type :json

          [200, {
            :page => 1,
            :orders => [
              { name: 'Order 1', amount: 9.99, description: nil },
              { name: 'Order 2', amount: 100.0, description: 'A great order' }
            ]
          }.to_json]
        end

        get '/orders/:id' do
          content_type :json

          [200, { order: { name: 'Order 1', amount: 100.0, description: 'A great order' } }.to_json]
        end

        post '/orders' do
          201
        end

        put '/orders/:id' do
          200
        end

        delete '/orders/:id' do
          200
        end

        get '/help' do
          [200, 'Welcome Henry !']
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
        config.format = :slate
        config.curl_host = 'http://localhost:3000'
        config.request_headers_to_include = %w[Content-Type Host]
        config.response_headers_to_include = %w[Content-Type Content-Length]
      end

      resource 'Orders' do
        get '/orders' do
          response_field :page, "Current page"

          example_request 'Getting a list of orders' do
            status.should eq(200)
            response_body.should eq('{"page":1,"orders":[{"name":"Order 1","amount":9.99,"description":null},{"name":"Order 2","amount":100.0,"description":"A great order"}]}')
          end
        end

        get '/orders/:id' do
          let(:id) { 1 }

          example_request 'Getting a specific order' do
            status.should eq(200)
            response_body.should == '{"order":{"name":"Order 1","amount":100.0,"description":"A great order"}}'
          end
        end

        post '/orders' do
          parameter :name, 'Name of order', :required => true
          parameter :amount, 'Amount paid', :required => true
          parameter :description, 'Some comments on the order'

          let(:name) { "Order 3" }
          let(:amount) { 33.0 }

          example_request 'Creating an order' do
            status.should == 201
          end
        end

        put '/orders/:id' do
          parameter :name, 'Name of order', :required => true
          parameter :amount, 'Amount paid', :required => true
          parameter :description, 'Some comments on the order'

          let(:id) { 2 }
          let(:name) { "Updated name" }

          example_request 'Updating an order' do
            status.should == 200
          end
        end

        delete "/orders/:id" do
          let(:id) { 1 }

          example_request "Deleting an order" do
            status.should == 200
          end
        end
      end

      resource 'Help' do
        get '/help' do
          example_request 'Getting welcome message' do
            status.should eq(200)
            response_body.should == 'Welcome Henry !'
          end
        end

      end
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output helpful progress to the console
    Then  the output should contain:
      """
      Generating API Docs
        Orders
        GET /orders
          * Getting a list of orders
        GET /orders/:id
          * Getting a specific order
        POST /orders
          * Creating an order
        PUT /orders/:id
          * Updating an order
        DELETE /orders/:id
          * Deleting an order
        Help
        GET /help
          * Getting welcome message
      """
    And   the output should contain "6 examples, 0 failures"
    And   the exit status should be 0

  Scenario: Example 'Getting a list of orders' docs should look like we expect
    Then the file "doc/api/_generated_examples.markdown" should contain:
    """
    ## Getting a list of orders

    ### Request

    #### Endpoint

    ```
    GET /orders
    Host: example.org
    ```

    `GET /orders`


    #### Parameters


    None known.


    ### Response

    ```
    Content-Type: application/json
    Content-Length: 137
    200 OK
    ```


    ```json
    {
      "page": 1,
      "orders": [
        {
          "name": "Order 1",
          "amount": 9.99,
          "description": null
        },
        {
          "name": "Order 2",
          "amount": 100.0,
          "description": "A great order"
        }
      ]
    }
    ```



    #### Fields

    | Name       | Description         |
    |:-----------|:--------------------|
    | page | Current page |



    ### cURL

    <code>curl&nbsp;"http://localhost:3000/orders"&nbsp;-X&nbsp;GET&nbsp;&#92;<br>&nbsp;&nbsp;-H&nbsp;"Host:&nbsp;example.org"&nbsp;&#92;<br>&nbsp;&nbsp;-H&nbsp;"Cookie:&nbsp;"</code>
    """

  Scenario: Example 'Creating an order' docs should look like we expect
    Then the file "doc/api/_generated_examples.markdown" should contain:
    """
    ## Creating an order

    ### Request

    #### Endpoint

    ```
    POST /orders
    Host: example.org
    Content-Type: application/x-www-form-urlencoded
    ```

    `POST /orders`


    #### Parameters


    ```json
    name=Order+3&amount=33.0
    ```


    | Name | Description |
    |:-----|:------------|
    | name *required* | Name of order |
    | amount *required* | Amount paid |
    | description  | Some comments on the order |



    ### Response

    ```
    Content-Type: text/html;charset=utf-8
    Content-Length: 0
    201 Created
    ```





    ### cURL

    <code>curl&nbsp;"http://localhost:3000/orders"&nbsp;-d&nbsp;'name=Order+3&amount=33.0'&nbsp;-X&nbsp;POST&nbsp;&#92;<br>&nbsp;&nbsp;-H&nbsp;"Host:&nbsp;example.org"&nbsp;&#92;<br>&nbsp;&nbsp;-H&nbsp;"Content-Type:&nbsp;application/x-www-form-urlencoded"&nbsp;&#92;<br>&nbsp;&nbsp;-H&nbsp;"Cookie:&nbsp;"</code>
    """

  Scenario: Example 'Deleting an order' docs should be created
    Then the file "doc/api/_generated_examples.markdown" should contain:
    """
    ## Deleting an order
    """

  Scenario: Example 'Getting a list of orders' docs should be created
    Then the file "doc/api/_generated_examples.markdown" should contain:
    """
    ## Getting a list of orders
    """

  Scenario: Example 'Getting a specific order' docs should be created
    Then the file "doc/api/_generated_examples.markdown" should contain:
    """
    ## Getting a specific order
    """

  Scenario: Example 'Updating an order' docs should be created
    Then the file "doc/api/_generated_examples.markdown" should contain:
    """
    ## Updating an order
    """

  Scenario: Example 'Getting welcome message' docs should be created
    Then the file "doc/api/_generated_examples.markdown" should contain:
    """
    ## Getting welcome message
    """
