Feature: Generate Open API Specification from test examples

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
            [200, request.body.read]
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
    And   a file named "open_api.json" with:
      """
      {
        "swagger": "2.0",
        "info": {
          "title": "OpenAPI App",
          "description": "This is a sample of OpenAPI specification.",
          "termsOfService": "http://open-api.io/terms/",
          "contact": {
            "name": "API Support",
            "url": "http://www.open-api.io/support",
            "email": "support@open-api.io"
          },
          "license": {
            "name": "Apache 2.0",
            "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
          },
          "version": "1.0.1"
        },
        "host": "localhost:3000",
        "schemes": [
          "http"
        ],
        "consumes": [
          "application/json"
        ],
        "produces": [
          "application/json"
        ],
        "tags": [
          {
            "name": "Orders",
            "description": "Order's tag description"
          }
        ],
        "paths": {
          "/should_be_hided": {
            "hide": true
          },
          "/not_hided": {
            "hide": false,
            "get": {
              "hide": true
            }
          },
          "/instructions": {
            "get": {
              "description": "This description came from config.yml 1"
            }
          },
          "/orders": {
            "post": {
              "description": "This description came from config.yml 2"
            }
          }
        }
      }
      """
    And   a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"

      RspecApiDocumentation.configure do |config|
        config.app = App
        config.api_name = "Example API"
        config.format = :open_api
        config.configurations_dir = "."
        config.request_body_formatter = :json
        config.request_headers_to_include = %w[Content-Type Host]
        config.response_headers_to_include = %w[Content-Type Content-Length]
      end

      resource 'Orders' do
        explanation "Orders resource"

        get '/orders' do
          route_summary "This URL allows users to interact with all orders."
          route_description "Long description."

          parameter :one_level_array, type: :array, items: {type: :string, enum: ['string1', 'string2']}, default: ['string1']
          parameter :two_level_array, type: :array, items: {type: :array, items: {type: :string}}

          parameter :one_level_arr, with_example: true
          parameter :two_level_arr, with_example: true

          let(:one_level_arr) { ['value1', 'value2'] }
          let(:two_level_arr) { [[5.1, 3.0], [1.0, 4.5]] }

          example_request 'Getting a list of orders' do
            expect(status).to eq(200)
            expect(response_body).to eq('{"page":1,"orders":[{"name":"Order 1","amount":9.99,"description":null},{"name":"Order 2","amount":100.0,"description":"A great order"}]}')
          end
        end

        post '/orders' do
          route_summary "This is used to create orders."

          header "Content-Type", "application/json"

          parameter :name, scope: :data, with_example: true, default: 'name'
          parameter :description, scope: :data, with_example: true
          parameter :amount, scope: :data, with_example: true, minimum: 0, maximum: 100
          parameter :values, scope: :data, with_example: true, enum: [1, 2, 3, 5]

          example 'Creating an order' do
            request = {
              data: {
                name: "Order 1",
                amount: 100.0,
                description: "A description",
                values: [5.0, 1.0]
              }
            }
            do_request(request)
            expect(status).to eq(201)
          end
        end

        get '/orders/:id' do
          route_summary "This is used to return orders."
          route_description "Returns a specific order."

          let(:id) { 1 }

          example_request 'Getting a specific order' do
            expect(status).to eq(200)
            expect(response_body).to eq('{"order":{"name":"Order 1","amount":100.0,"description":"A great order"}}')
          end
        end

        put '/orders/:id' do
          route_summary "This is used to update orders."

          parameter :name, 'The order name', required: true, scope: :data, with_example: true
          parameter :amount, required: false, scope: :data, with_example: true
          parameter :description, 'The order description', required: true, scope: :data, with_example: true

          header "Content-Type", "application/json"

          context "with a valid id" do
            let(:id) { 1 }

            example 'Update an order' do
              request = {
                data: {
                  name: 'order',
                  amount: 1,
                  description: 'fast order'
                }
              }
              do_request(request)
              expected_response = {
                data: {
                  name: 'order',
                  amount: 1,
                  description: 'fast order'
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

        delete '/orders/:id' do
          route_summary "This is used to delete orders."

          let(:id) { 1 }

          example_request "Deleting an order" do
            expect(status).to eq(200)
            expect(response_body).to eq('')
          end
        end
      end

      resource 'Instructions' do
        explanation 'Instructions help the users use the app.'

        get '/instructions' do
          route_summary 'This should be used to get all instructions.'

          example_request 'List all instructions' do
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
      """
    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

  Scenario: Output helpful progress to the console
    Then  the output should contain:
      """
      Generating API Docs
        Orders
        GET /orders
          * Getting a list of orders
        POST /orders
          * Creating an order
        GET /orders/:id
          * Getting a specific order
        PUT /orders/:id
        with a valid id
          * Update an order
        with an invalid id
          * Invalid request
        DELETE /orders/:id
          * Deleting an order
        Instructions
        GET /instructions
          * List all instructions
      """
    And   the output should contain "7 examples, 0 failures"
    And   the exit status should be 0

  Scenario: Index file should look like we expect
    Then the file "doc/api/open_api.json" should contain exactly:
    """
    {
      "swagger": "2.0",
      "info": {
        "title": "OpenAPI App",
        "description": "This is a sample of OpenAPI specification.",
        "termsOfService": "http://open-api.io/terms/",
        "contact": {
          "name": "API Support",
          "url": "http://www.open-api.io/support",
          "email": "support@open-api.io"
        },
        "license": {
          "name": "Apache 2.0",
          "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
        },
        "version": "1.0.1"
      },
      "host": "localhost:3000",
      "schemes": [
        "http"
      ],
      "consumes": [
        "application/json"
      ],
      "produces": [
        "application/json"
      ],
      "paths": {
        "/not_hided": {
        },
        "/instructions": {
          "get": {
            "tags": [
              "Instructions"
            ],
            "summary": "This should be used to get all instructions.",
            "description": "This description came from config.yml 1",
            "consumes": [

            ],
            "produces": [
              "text/html"
            ],
            "parameters": [

            ],
            "responses": {
              "200": {
                "description": "List all instructions",
                "schema": {
                  "type": "object",
                  "properties": {
                  }
                },
                "headers": {
                  "Content-Type": {
                    "type": "string",
                    "x-example-value": "text/html;charset=utf-8"
                  },
                  "Content-Length": {
                    "type": "string",
                    "x-example-value": "57"
                  }
                },
                "examples": {
                  "text/html": {
                    "data": {
                      "id": "1",
                      "type": "instructions",
                      "attributes": {
                      }
                    }
                  }
                }
              }
            },
            "deprecated": false,
            "security": [

            ]
          }
        },
        "/orders": {
          "get": {
            "tags": [
              "Orders"
            ],
            "summary": "This URL allows users to interact with all orders.",
            "description": "Long description.",
            "consumes": [

            ],
            "produces": [
              "application/vnd.api+json"
            ],
            "parameters": [
              {
                "name": "one_level_array",
                "in": "query",
                "description": " one level array",
                "required": false,
                "type": "array",
                "items": {
                  "type": "string",
                  "enum": [
                    "string1",
                    "string2"
                  ]
                },
                "default": [
                  "string1"
                ]
              },
              {
                "name": "two_level_array",
                "in": "query",
                "description": " two level array",
                "required": false,
                "type": "array",
                "items": {
                  "type": "array",
                  "items": {
                    "type": "string"
                  }
                }
              },
              {
                "name": "one_level_arr",
                "in": "query",
                "description": " one level arr",
                "required": false,
                "type": "array",
                "items": {
                  "type": "string"
                },
                "example": [
                  "value1",
                  "value2"
                ]
              },
              {
                "name": "two_level_arr",
                "in": "query",
                "description": " two level arr",
                "required": false,
                "type": "array",
                "items": {
                  "type": "array",
                  "items": {
                    "type": "number"
                  }
                },
                "example": [
                  [
                    5.1,
                    3.0
                  ],
                  [
                    1.0,
                    4.5
                  ]
                ]
              }
            ],
            "responses": {
              "200": {
                "description": "Getting a list of orders",
                "schema": {
                  "type": "object",
                  "properties": {
                  }
                },
                "headers": {
                  "Content-Type": {
                    "type": "string",
                    "x-example-value": "application/vnd.api+json"
                  },
                  "Content-Length": {
                    "type": "string",
                    "x-example-value": "137"
                  }
                },
                "examples": {
                  "application/vnd.api+json": {
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
                }
              }
            },
            "deprecated": false,
            "security": [

            ]
          },
          "post": {
            "tags": [
              "Orders"
            ],
            "summary": "This is used to create orders.",
            "description": "This description came from config.yml 2",
            "consumes": [
              "application/json"
            ],
            "produces": [
              "application/json"
            ],
            "parameters": [
              {
                "name": "body",
                "in": "body",
                "description": "",
                "required": false,
                "schema": {
                  "type": "object",
                  "properties": {
                    "data": {
                      "type": "object",
                      "properties": {
                        "name": {
                          "type": "string",
                          "example": "Order 1",
                          "default": "name",
                          "description": "Data name"
                        },
                        "description": {
                          "type": "string",
                          "example": "A description",
                          "description": "Data description"
                        },
                        "amount": {
                          "type": "number",
                          "example": 100.0,
                          "description": "Data amount",
                          "minimum": 0,
                          "maximum": 100
                        },
                        "values": {
                          "type": "array",
                          "example": [
                            5.0,
                            1.0
                          ],
                          "description": "Data values",
                          "items": {
                            "type": "number",
                            "enum": [
                              1,
                              2,
                              3,
                              5
                            ]
                          }
                        }
                      }
                    }
                  }
                }
              }
            ],
            "responses": {
              "201": {
                "description": "Creating an order",
                "schema": {
                  "type": "object",
                  "properties": {
                  }
                },
                "headers": {
                  "Content-Type": {
                    "type": "string",
                    "x-example-value": "application/json"
                  },
                  "Content-Length": {
                    "type": "string",
                    "x-example-value": "73"
                  }
                },
                "examples": {
                  "application/json": {
                    "order": {
                      "name": "Order 1",
                      "amount": 100.0,
                      "description": "A great order"
                    }
                  }
                }
              }
            },
            "deprecated": false,
            "security": [

            ]
          }
        },
        "/orders/{id}": {
          "get": {
            "tags": [
              "Orders"
            ],
            "summary": "This is used to return orders.",
            "description": "Returns a specific order.",
            "consumes": [

            ],
            "produces": [
              "application/json"
            ],
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "required": true,
                "type": "integer"
              }
            ],
            "responses": {
              "200": {
                "description": "Getting a specific order",
                "schema": {
                  "type": "object",
                  "properties": {
                  }
                },
                "headers": {
                  "Content-Type": {
                    "type": "string",
                    "x-example-value": "application/json"
                  },
                  "Content-Length": {
                    "type": "string",
                    "x-example-value": "73"
                  }
                },
                "examples": {
                  "application/json": {
                    "order": {
                      "name": "Order 1",
                      "amount": 100.0,
                      "description": "A great order"
                    }
                  }
                }
              }
            },
            "deprecated": false,
            "security": [

            ]
          },
          "put": {
            "tags": [
              "Orders"
            ],
            "summary": "This is used to update orders.",
            "description": "",
            "consumes": [
              "application/json"
            ],
            "produces": [
              "application/json"
            ],
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "required": true,
                "type": "integer"
              },
              {
                "name": "body",
                "in": "body",
                "description": "",
                "required": false,
                "schema": {
                  "type": "object",
                  "properties": {
                    "data": {
                      "type": "object",
                      "properties": {
                        "name": {
                          "type": "string",
                          "example": "order",
                          "description": "The order name"
                        },
                        "amount": {
                          "type": "integer",
                          "example": 1,
                          "description": "Data amount"
                        },
                        "description": {
                          "type": "string",
                          "example": "fast order",
                          "description": "The order description"
                        }
                      },
                      "required": [
                        "name",
                        "description"
                      ]
                    }
                  }
                }
              }
            ],
            "responses": {
              "200": {
                "description": "Update an order",
                "schema": {
                  "type": "object",
                  "properties": {
                  }
                },
                "headers": {
                  "Content-Type": {
                    "type": "string",
                    "x-example-value": "application/json"
                  },
                  "Content-Length": {
                    "type": "string",
                    "x-example-value": "63"
                  }
                },
                "examples": {
                }
              },
              "400": {
                "description": "Invalid request",
                "schema": {
                  "type": "object",
                  "properties": {
                  }
                },
                "headers": {
                  "Content-Type": {
                    "type": "string",
                    "x-example-value": "application/json"
                  },
                  "Content-Length": {
                    "type": "string",
                    "x-example-value": "0"
                  }
                },
                "examples": {
                }
              }
            },
            "deprecated": false,
            "security": [

            ]
          },
          "delete": {
            "tags": [
              "Orders"
            ],
            "summary": "This is used to delete orders.",
            "description": "",
            "consumes": [
              "application/x-www-form-urlencoded"
            ],
            "produces": [
              "text/html"
            ],
            "parameters": [
              {
                "name": "id",
                "in": "path",
                "required": true,
                "type": "integer"
              }
            ],
            "responses": {
              "200": {
                "description": "Deleting an order",
                "schema": {
                  "type": "object",
                  "properties": {
                  }
                },
                "headers": {
                  "Content-Type": {
                    "type": "string",
                    "x-example-value": "text/html;charset=utf-8"
                  },
                  "Content-Length": {
                    "type": "string",
                    "x-example-value": "0"
                  }
                },
                "examples": {
                }
              }
            },
            "deprecated": false,
            "security": [

            ]
          }
        }
      },
      "tags": [
        {
          "name": "Orders",
          "description": "Order's tag description"
        },
        {
          "name": "Instructions",
          "description": "Instructions help the users use the app."
        }
      ]
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
