Feature: Generate Textile documentation from test examples

  Background:
    Given a file named "app.rb" with:
      """
      require 'sinatra'

      class App < Sinatra::Base
        get '/orders' do
          content_type :json

          [200, [{ name: 'Order 1', amount: 9.99, description: nil },
                 { name: 'Order 2', amount: 100.0, description: 'A great order' }].to_json]
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
        config.format = :textile
      end

      resource 'Orders' do
        get '/orders' do

          example_request 'Getting a list of orders' do
            status.should eq(200)
            response_body.should eq('[{"name":"Order 1","amount":9.99,"description":null},{"name":"Order 2","amount":100.0,"description":"A great order"}]')
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

  Scenario: Index file should look like we expect
    Then the file "doc/api/index.textile" should contain exactly:
    """
    h1. Example API

    h2. Help

    * "Getting welcome message":help/getting_welcome_message.textile

    h2. Orders

    * "Creating an order":orders/creating_an_order.textile
    * "Deleting an order":orders/deleting_an_order.textile
    * "Getting a list of orders":orders/getting_a_list_of_orders.textile
    * "Getting a specific order":orders/getting_a_specific_order.textile
    * "Updating an order":orders/updating_an_order.textile


    """

  Scenario: Example 'Creating an order' file should look like we expect
    Then the file "doc/api/orders/creating_an_order.textile" should contain exactly:
    """
    h1. Orders API

    h2. Creating an order

    h3. POST /orders


    h3. Parameters

    Name : name  *- required -*
    Description : Name of order

    Name : amount  *- required -*
    Description : Amount paid

    Name : description 
    Description : Some comments on the order

    h3. Request

    h4. Headers

    <pre>Host: example.org
    Content-Type: application/x-www-form-urlencoded
    Cookie: </pre>

    h4. Route

    <pre>POST /orders</pre>


    h4. Body

    <pre>name=Order+3&amount=33.0</pre>


    h3. Response

    h4. Headers

    <pre>X-Frame-Options: sameorigin
    X-XSS-Protection: 1; mode=block
    Content-Type: text/html;charset=utf-8
    Content-Length: 0</pre>

    h4. Status

    <pre>201 Created</pre>




    """

  Scenario: Example 'Deleting an order' file should be created
    Then a file named "doc/api/orders/deleting_an_order.textile" should exist

  Scenario: Example 'Getting a list of orders' file should be created
    Then a file named "doc/api/orders/getting_a_list_of_orders.textile" should exist

  Scenario: Example 'Getting a specific order' file should be created
    Then a file named "doc/api/orders/getting_a_specific_order.textile" should exist

  Scenario: Example 'Updating an order' file should be created
    Then a file named "doc/api/orders/updating_an_order.textile" should exist

  Scenario: Example 'Getting welcome message' file should be created
    Then a file named "doc/api/help/getting_welcome_message.textile" should exist


