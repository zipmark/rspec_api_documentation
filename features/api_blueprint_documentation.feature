Feature: Generate API Blueprint documentation from test examples

  Background:
    Given a file named "app.rb" with:
      """
      require 'sinatra'

      class App < Sinatra::Base
        get '/orders' do
          content_type "application/vnd.api+json"

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
          content_type :json

          [201, { order: { name: 'Order 1', amount: 100.0, description: 'A great order' } }.to_json]
        end

        put '/orders/:id' do
          content_type :json

          if params[:id].to_i > 0
            [200, { data: { id: "1", type: "order", attributes: { name: "Order 1", amount: 100.0, description: "A description" } } }.to_json]
          else
            [400, ""]
          end
        end

        delete '/orders/:id' do
          200
        end

        get '/instructions' do
          response_body = {
            data: {
              id: "1",
              type: "instructions",
              attributes: {}
            }
          }
          [200, response_body.to_json]
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
        config.api_explanation = "Example API Description"
        config.format = :api_blueprint
        config.request_body_formatter = :json
        config.request_headers_to_include = %w[Content-Type Host]
        config.response_headers_to_include = %w[Content-Type Content-Length]
      end

      resource 'Orders' do
        explanation "Orders resource"

        route '/orders', 'Orders Collection' do
          explanation "This URL allows users to interact with all orders."

          get 'Return all orders' do
            explanation "This is used to return all orders."

            example_request 'Getting a list of orders' do
              expect(status).to eq(200)
              expect(response_body).to eq('{"page":1,"orders":[{"name":"Order 1","amount":9.99,"description":null},{"name":"Order 2","amount":100.0,"description":"A great order"}]}')
            end
          end

          post 'Creates an order' do
            explanation "This is used to create orders."

            header "Content-Type", "application/json"

            example 'Creating an order' do
              request = {
                data: {
                  type: "order",
                  attributes: {
                    name: "Order 1",
                    amount: 100.0,
                    description: "A description"
                  }
                }
              }
              do_request(request)
              expect(status).to eq(201)
            end
          end
        end

        route '/orders/:id{?optional=:optional}', "Single Order" do
          parameter :id, 'Order id', required: true, type: 'string', :example => '1'
          parameter :optional

          attribute :name, 'The order name', required: true, :example => 'a name'
          attribute :amount, required: false
          attribute :description, 'The order description', type: 'string', required: false, example: "a description"
          attribute :category, 'The order category', type: 'string', required: false, default: 'normal', enum: %w[normal priority]
          attribute :metadata, 'The order metadata', type: 'json', required: false, annotation: <<-MARKDOWN
    + instructions (optional, string)
    + notes (optional, string)
          MARKDOWN

          get 'Returns a single order' do
            explanation "This is used to return orders."

            let(:id) { 1 }

            example_request 'Getting a specific order' do
              explanation 'Returns a specific order.'

              expect(status).to eq(200)
              expect(response_body).to eq('{"order":{"name":"Order 1","amount":100.0,"description":"A great order"}}')
            end
          end

          put 'Updates a single order' do
            explanation "This is used to update orders."

            header "Content-Type", "application/json; charset=utf-16"

            context "with a valid id" do
              let(:id) { 1 }

              example 'Update an order' do
                request = {
                  data: {
                    id: "1",
                    type: "order",
                    attributes: {
                      name: "Order 1",
                    }
                  }
                }
                do_request(request)
                expected_response = {
                  data: {
                    id: "1",
                    type: "order",
                    attributes: {
                      name: "Order 1",
                      amount: 100.0,
                      description: "A description",
                    }
                  }
                }
                expect(status).to eq(200)
                expect(response_body).to eq(expected_response.to_json)
              end
            end

            context "with an invalid id" do
              let(:id) { "a" }

              example_request 'Invalid request' do
                expect(status).to eq(400)
                expect(response_body).to eq("")
              end
            end
          end

          delete "Deletes a specific order" do
            explanation "This is used to delete orders."

            let(:id) { 1 }

            example_request "Deleting an order" do
              explanation 'Deletes the requested order.'

              expect(status).to eq(200)
              expect(response_body).to eq('')
            end
          end
        end
      end

      resource 'Instructions' do
        explanation 'Instructions help the users use the app.'

        route '/instructions', 'Instructions Collection' do
          explanation 'This endpoint allows users to interact with all instructions.'

          get 'Returns all instructions' do
            explanation 'This should be used to get all instructions.'

            example_request 'List all instructions' do
              explanation 'Returns all instructions.'

              expected_response = {
                data: {
                  id: "1",
                  type: "instructions",
                  attributes: {}
                }
              }
              expect(status).to eq(200)
              expect(response_body).to eq(expected_response.to_json)
            end
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
        /orders Orders Collection
        GET Return all orders
          * Getting a list of orders
        POST Creates an order
          * Creating an order
        /orders/:id{?optional=:optional} Single Order
        GET Returns a single order
          * Getting a specific order
        PUT Updates a single order
        with a valid id
          * Update an order
        with an invalid id
          * Invalid request
        DELETE Deletes a specific order
          * Deleting an order
        Instructions
        /instructions Instructions Collection
        GET Returns all instructions
          * List all instructions
      """
    And   the output should contain "7 examples, 0 failures"
    And   the exit status should be 0

  Scenario: Index file should look like we expect
    Then the file "doc/api/index.apib" should contain exactly:
    """
    FORMAT: 1A
    # Example API
    Example API Description

    # Group Instructions

    Instructions help the users use the app.

    ## Instructions Collection [/instructions]

    ### Returns all instructions [GET]

    + Request List all instructions

        + Headers

                Host: example.org

    + Response 200 (text/html;charset=utf-8)

        + Headers

                Content-Length: 57

        + Body

                {"data":{"id":"1","type":"instructions","attributes":{}}}

    # Group Orders

    Orders resource

    ## Orders Collection [/orders]

    ### Creates an order [POST]

    + Request Creating an order (application/json)

        + Headers

                Host: example.org

        + Body

                {
                  "data": {
                    "type": "order",
                    "attributes": {
                      "name": "Order 1",
                      "amount": 100.0,
                      "description": "A description"
                    }
                  }
                }

    + Response 201 (application/json)

        + Headers

                Content-Length: 73

        + Body

                {
                  "order": {
                    "name": "Order 1",
                    "amount": 100.0,
                    "description": "A great order"
                  }
                }

    ### Return all orders [GET]

    + Request Getting a list of orders

        + Headers

                Host: example.org

    + Response 200 (application/vnd.api+json)

        + Headers

                Content-Length: 137

        + Body

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

    ## Single Order [/orders/{id}{?optional=:optional}]

    + Parameters
      + id: 1 (required, string) - Order id
      + optional (optional)

    + Attributes (object)
      + name: a name (required) - The order name
      + amount (optional)
      + description: a description (optional, string) - The order description
      + category (optional, string) - The order category
          + Default: `normal`
          + Members
              + `normal`
              + `priority`
      + metadata (optional, json) - The order metadata
          + instructions (optional, string)
          + notes (optional, string)

    ### Deletes a specific order [DELETE]

    + Request Deleting an order (application/x-www-form-urlencoded)

        + Headers

                Host: example.org

    + Response 200 (text/html;charset=utf-8)

        + Headers

                Content-Length: 0

    ### Returns a single order [GET]

    + Request Getting a specific order

        + Headers

                Host: example.org

    + Response 200 (application/json)

        + Headers

                Content-Length: 73

        + Body

                {
                  "order": {
                    "name": "Order 1",
                    "amount": 100.0,
                    "description": "A great order"
                  }
                }

    ### Updates a single order [PUT]

    + Request Invalid request (application/json; charset=utf-16)

        + Headers

                Host: example.org

    + Response 400 (application/json)

        + Headers

                Content-Length: 0

    + Request Update an order (application/json; charset=utf-16)

        + Headers

                Host: example.org

        + Body

                {
                  "data": {
                    "id": "1",
                    "type": "order",
                    "attributes": {
                      "name": "Order 1"
                    }
                  }
                }

    + Response 200 (application/json)

        + Headers

                Content-Length: 111

        + Body

                {
                  "data": {
                    "id": "1",
                    "type": "order",
                    "attributes": {
                      "name": "Order 1",
                      "amount": 100.0,
                      "description": "A description"
                    }
                  }
                }
    """

  Scenario: Example 'Deleting an order' file should not be created
    Then a file named "doc/api/orders/deleting_an_order.apib" should not exist

  Scenario: Example 'Getting a list of orders' file should be created
    Then a file named "doc/api/orders/getting_a_list_of_orders.apib" should not exist

  Scenario: Example 'Getting a specific order' file should be created
    Then a file named "doc/api/orders/getting_a_specific_order.apib" should not exist

  Scenario: Example 'Updating an order' file should be created
    Then a file named "doc/api/orders/updating_an_order.apib" should not exist

  Scenario: Example 'Getting welcome message' file should be created
    Then a file named "doc/api/help/getting_welcome_message.apib" should not exist
