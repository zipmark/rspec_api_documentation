[![Build Status](https://travis-ci.org/zipmark/rspec_api_documentation.svg?branch=master)](https://travis-ci.org/zipmark/rspec_api_documentation)
[![Dependency Status](https://gemnasium.com/badges/github.com/zipmark/rspec_api_documentation.svg)](https://gemnasium.com/github.com/zipmark/rspec_api_documentation)
[![Code Climate](https://codeclimate.com/github/zipmark/rspec_api_documentation/badges/gpa.svg)](https://codeclimate.com/github/zipmark/rspec_api_documentation)
[![Inline docs](https://inch-ci.org/github/zipmark/rspec_api_documentation.svg?branch=master)](https://inch-ci.org/github/zipmark/rspec_api_documentation)
[![Gem Version](https://badge.fury.io/rb/rspec_api_documentation.svg)](https://badge.fury.io/rb/rspec_api_documentation)

# RSpec API Doc Generator

Generate pretty API docs for your Rails APIs.

Check out a [sample](http://rad-example.herokuapp.com).

## Changes

Please see the wiki for latest [changes](https://github.com/zipmark/rspec_api_documentation/wiki/Changes).

## Installation

Add rspec_api_documentation to your Gemfile

    gem 'rspec_api_documentation'

Bundle it!

    $ bundle install

Set up specs.

    $ mkdir spec/acceptance
    $ vim spec/acceptance/orders_spec.rb

```ruby
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Orders" do
  get "/orders" do
    example "Listing orders" do
      do_request

      expect(status).to eq 200
    end
  end
end
```

Generate the docs!

    $ rake docs:generate
    $ open doc/api/index.html

### Viewers

Consider adding a viewer to enhance the generated documentation. By itself rspec_api_documentation will generate very simple HTML. All viewers use the generated JSON.

* [Raddocs](http://github.com/smartlogic/raddocs/) - Sinatra app
* [Apitome](https://github.com/modeset/apitome) - Rails engine

#### Gemfile

    gem 'raddocs'

    or 

    gem 'apitome'

#### spec/spec_helper.rb

```ruby
RspecApiDocumentation.configure do |config|
  config.format = :json
end
```

####
For both raddocs and apitome, start rails server. Then

    open http://localhost:3000/docs for raddocs

    or

    http://localhost:3000/api/docs for apitome

## Sample App

See the `example` folder for a sample Rails app that has been documented.  The sample app demonstrates the :open_api format.

## Example of spec file

```ruby
  # spec/acceptance/orders_spec.rb
  require 'rails_helper'
  require 'rspec_api_documentation/dsl'
  resource 'Orders' do
    explanation "Orders resource"
    
    header "Content-Type", "application/json"

    get '/orders' do
      # This is manual way to describe complex parameters
      parameter :one_level_array, type: :array, items: {type: :string, enum: ['string1', 'string2']}, default: ['string1']
      parameter :two_level_array, type: :array, items: {type: :array, items: {type: :string}}
      
      let(:one_level_array) { ['string1', 'string2'] }
      let(:two_level_array) { [['123', '234'], ['111']] }

      # This is automatic way
      # It's possible because we extract parameters definitions from the values
      parameter :one_level_arr, with_example: true
      parameter :two_level_arr, with_example: true

      let(:one_level_arr) { ['value1', 'value2'] }
      let(:two_level_arr) { [[5.1, 3.0], [1.0, 4.5]] }

      context '200' do
        example_request 'Getting a list of orders' do
          expect(status).to eq(200)
        end
      end
    end

    put '/orders/:id' do

      with_options scope: :data, with_example: true do
        parameter :name, 'The order name', required: true
        parameter :amount
        parameter :description, 'The order description'
      end

      context "200" do
        let(:id) { 1 }

        example 'Update an order' do
          request = {
            data: {
              name: 'order',
              amount: 1,
              description: 'fast order'
            }
          }
          
          # It's also possible to extract types of parameters when you pass data through `do_request` method.
          do_request(request)
          
          expected_response = {
            data: {
              name: 'order',
              amount: 1,
              description: 'fast order'
            }
          }
          expect(status).to eq(200)
          expect(response_body).to eq(expected_response)
        end
      end

      context "400" do
        let(:id) { "a" }

        example_request 'Invalid request' do
          expect(status).to eq(400)
        end
      end
      
      context "404" do
        let(:id) { 0 }
        
        example_request 'Order is not found' do
          expect(status).to eq(404)
        end
      end
    end
  end
```


## Configuration options
```ruby
# Values listed are the default values
RspecApiDocumentation.configure do |config|
  # Set the application that Rack::Test uses
  config.app = Rails.application

  # Used to provide a configuration for the specification (supported only by 'open_api' format for now) 
  config.configurations_dir = Rails.root.join("doc", "configurations", "api")

  # Output folder
  config.docs_dir = Rails.root.join("doc", "api")

  # An array of output format(s).
  # Possible values are :json, :html, :combined_text, :combined_json,
  #   :json_iodocs, :textile, :markdown, :append_json, :slate,
  #   :api_blueprint, :open_api
  config.format = [:html]

  # Location of templates
  config.template_path = "inside of the gem"

  # Filter by example document type
  config.filter = :all

  # Filter by example document type
  config.exclusion_filter = nil

  # Used when adding a cURL output to the docs
  config.curl_host = nil

  # Used when adding a cURL output to the docs
  # Allows you to filter out headers that are not needed in the cURL request,
  # such as "Host" and "Cookie". Set as an array.
  config.curl_headers_to_filter = nil

  # By default, when these settings are nil, all headers are shown,
  # which is sometimes too chatty. Setting the parameters to an
  # array of headers will render *only* those headers.
  config.request_headers_to_include = nil
  config.response_headers_to_include = nil

  # By default examples and resources are ordered by description. Set to true keep
  # the source order.
  config.keep_source_order = false

  # Change the name of the API on index pages
  config.api_name = "API Documentation"
  
  # Change the description of the API on index pages
  config.api_explanation = "API Description"

  # Redefine what method the DSL thinks is the client
  # This is useful if you need to `let` your own client, most likely a model.
  config.client_method = :client

  # Change the IODocs writer protocol
  config.io_docs_protocol = "http"

  # You can define documentation groups as well. A group allows you generate multiple
  # sets of documentation.
  config.define_group :public do |config|
    # By default the group's doc_dir is a subfolder under the parent group, based
    # on the group's name.
    config.docs_dir = Rails.root.join("doc", "api", "public")

    # Change the filter to only include :public examples
    config.filter = :public
  end

  # Change how the post body is formatted by default, you can still override by `raw_post`
  # Can be :json, :xml, or a proc that will be passed the params
  config.request_body_formatter = Proc.new { |params| params }

  # Change how the response body is formatted by default
  # Is proc that will be called with the response_content_type & response_body
  # by default response_content_type of `application/json` are pretty formated.
  config.response_body_formatter = Proc.new { |response_content_type, response_body| response_body }

  # Change the embedded style for HTML output. This file will not be processed by
  # RspecApiDocumentation and should be plain CSS.
  config.html_embedded_css_file = nil

  # Removes the DSL method `status`, this is required if you have a parameter named status
  # In this case you can assert response status with `expect(response_status).to eq 200`
  config.disable_dsl_status!

  # Removes the DSL method `method`, this is required if you have a parameter named method
  config.disable_dsl_method!
end
```

## Format

* **json**: Generates an index file and example files in JSON.
* **html**: Generates an index file and example files in HTML.
* **combined_text**: Generates a single file for each resource. Used by [Raddocs](http://github.com/smartlogic/raddocs) for command line docs.
* **combined_json**: Generates a single file for all examples.
* **json_iodocs**: Generates [I/O Docs](http://www.mashery.com/product/io-docs) style documentation.
* **textile**: Generates an index file and example files in Textile.
* **markdown**: Generates an index file and example files in Markdown.
* **api_blueprint**: Generates an index file and example files in [APIBlueprint](https://apiblueprint.org).
* **append_json**: Lets you selectively run specs without destroying current documentation. See section below.
* **slate**: Builds markdown files that can be used with [Slate](https://github.com/lord/slate), a beautiful static documentation builder.
* **open_api**: Generates [OpenAPI Specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md) (OAS) (Current supported version is 2.0). Can be used for [Swagger-UI](https://swagger.io/tools/swagger-ui/) 

### append_json

This format cannot be run with other formats as they will delete the entire documentation folder upon each run. This format appends new examples to the index file, and writes all run examples in the correct folder.

Below is a rake task that allows this format to be used easily.

```ruby
RSpec::Core::RakeTask.new('docs:generate:append', :spec_file) do |t, task_args|
  if spec_file = task_args[:spec_file]
    ENV["DOC_FORMAT"] = "append_json"
  end
  t.pattern    = spec_file || 'spec/acceptance/**/*_spec.rb'
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter"]
end
```

And in your `spec/spec_helper.rb`:

```ruby
ENV["DOC_FORMAT"] ||= "json"

RspecApiDocumentation.configure do |config|
  config.format    = ENV["DOC_FORMAT"]
end
```

```bash
rake docs:generate:append[spec/acceptance/orders_spec.rb]
```

This will update the current index's examples to include any in the `orders_spec.rb` file. Any examples inside will be rewritten.

### api_blueprint

This [format](https://apiblueprint.org) (APIB) has additional functions:

* `route`: APIB groups URLs together and then below them are HTTP verbs.

  ```ruby
  route "/orders", "Orders Collection" do
    get "Returns all orders" do
      # ...
    end

    delete "Deletes all orders" do
      # ...
    end
  end
  ```

  If you don't use `route`, then param in `get(param)` should be an URL as
  states in the rest of this documentation.

* `attribute`: APIB has attributes besides parameters. Use attributes exactly
  like you'd use `parameter` (see documentation below).
  
### open_api 

This [format](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md) (OAS) has additional functions:

* `authentication(type, value, opts = {})` ([Security schema object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#security-scheme-object))

    The values will be passed through header of the request. Option `name` has to be provided for `apiKey`. 
    
    * `authentication :basic, 'Basic Key'`
    * `authentication :apiKey, 'Api Key', name: 'API_AUTH', description: 'Some description'`
    
    You could pass `Symbol` as value. In this case you need to define a `let` with the same name.
    
    ```
    authentication :apiKey, :api_key
    let(:api_key) { some_value } 
    ```
    
* `route_summary(text)` and `route_description(text)`. ([Operation object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#operation-object)) 

    These two simplest methods accept `String`. 
    It will be used for route's `summary` and `description`. 
    
* Several new options on `parameter` helper.

    - `with_example: true`. This option will adjust your example of the parameter with the passed value.
    - `example: <value>`. Will provide a example value for the parameter.
    - `default: <value>`. Will provide a default value for the parameter.
    - `minimum: <integer>`. Will setup upper limit for your parameter. 
    - `maximum: <integer>`. Will setup lower limit for your parameter.
    - `enum: [<value>, <value>, ..]`. Will provide a pre-defined list of possible values for your parameter.
    - `type: [:file, :array, :object, :boolean, :integer, :number, :string]`. Will set a type for the parameter. Most of the type you don't need to provide this option manually. We extract types from values automatically.


You also can provide a configuration file in YAML or JSON format with some manual configs. 
The file should be placed in `configurations_dir` folder with the name `open_api.yml` or `open_api.json`. 
In this file you able to manually **hide** some endpoints/resources you want to hide from generated API specification but still want to test. 
It's also possible to pass almost everything to the specification builder manually.

#### Example of configuration file

```yaml
swagger: '2.0'
info:
  title: OpenAPI App
  description: This is a sample server.
  termsOfService: 'http://open-api.io/terms/'
  contact:
    name: API Support
    url: 'http://www.open-api.io/support'
    email: support@open-api.io
  license:
    name: Apache 2.0
    url: 'http://www.apache.org/licenses/LICENSE-2.0.html'
  version: 1.0.0
host: 'localhost:3000'
schemes:
  - http
  - https
consumes:
  - application/json
  - application/xml
produces:
  - application/json
  - application/xml
paths: 
  /orders:
    hide: true
  /instructions:
    hide: false
    get:
      description: This description came from configuration file
      hide: true
```
#### Example of spec file with :open_api format
```ruby
  resource 'Orders' do
    explanation "Orders resource"
    
    authentication :apiKey, :api_key, description: 'Private key for API access', name: 'HEADER_KEY'
    header "Content-Type", "application/json"
    
    let(:api_key) { generate_api_key }

    get '/orders' do
      route_summary "This URL allows users to interact with all orders."
      route_description "Long description."

      # This is manual way to describe complex parameters
      parameter :one_level_array, type: :array, items: {type: :string, enum: ['string1', 'string2']}, default: ['string1']
      parameter :two_level_array, type: :array, items: {type: :array, items: {type: :string}}
      
      let(:one_level_array) { ['string1', 'string2'] }
      let(:two_level_array) { [['123', '234'], ['111']] }

      # This is automatic way
      # It's possible because we extract parameters definitions from the values
      parameter :one_level_arr, with_example: true
      parameter :two_level_arr, with_example: true

      let(:one_level_arr) { ['value1', 'value2'] }
      let(:two_level_arr) { [[5.1, 3.0], [1.0, 4.5]] }

      context '200' do
        example_request 'Getting a list of orders' do
          expect(status).to eq(200)
          expect(response_body).to eq(<response>)
        end
      end
    end

    put '/orders/:id' do
      route_summary "This is used to update orders."

      with_options scope: :data, with_example: true do
        parameter :name, 'The order name', required: true
        parameter :amount
        parameter :description, 'The order description'
      end

      context "200" do
        let(:id) { 1 }

        example 'Update an order' do
          request = {
            data: {
              name: 'order',
              amount: 1,
              description: 'fast order'
            }
          }
          
          # It's also possible to extract types of parameters when you pass data through `do_request` method.
          do_request(request)
          
          expected_response = {
            data: {
              name: 'order',
              amount: 1,
              description: 'fast order'
            }
          }
          expect(status).to eq(200)
          expect(response_body).to eq(<response>)
        end
      end

      context "400" do
        let(:id) { "a" }

        example_request 'Invalid request' do
          expect(status).to eq(400)
        end
      end
      
      context "404" do
        let(:id) { 0 }
        
        example_request 'Order is not found' do
          expect(status).to eq(404)
        end
      end
    end
  end
```

## Filtering and Exclusion

rspec_api_documentation lets you determine which examples get outputted into the final documentation.
All filtering is done via the `:document` metadata key.
You tag examples with either a single symbol or an array of symbols.
`:document` can also be false, which will make sure it does not get outputted.

```ruby
resource "Account" do
  get "/accounts" do
    parameter :page, "Page to view"

    # default :document is :all
    example "Get a list of all accounts" do
      do_request
      expect(status).to eq 200
    end

    # Don't actually document this example, purely for testing purposes
    example "Get a list on page 2", :document => false do
      do_request(:page => 2)
      expect(status).to eq 404
    end

    # With example_request, you can't change the :document
    example_request "Get a list on page 3", :page => 3 do
      expect(status).to eq 404
    end
  end

  post "/accounts" do
    parameter :email, "User email"

    example "Creating an account", :document => :private do
      do_request(:email => "eric@example.com")
      expect(status).to eq 201
    end

    example "Creating an account - errors", :document => [:private, :developers] do
      do_request
      expect(status).to eq 422
    end
  end
end
```

```ruby
# All documents will be generated into the top folder, :document => false
# examples will never be generated.
RspecApiDocumentation.configure do |config|
  # Exclude only document examples marked as 'private'
  config.define_group :non_private do |config|
    config.exclusion_filter = :private
  end

  # Only document examples marked as 'public'
  config.define_group :public do |config|
    config.filter = :public
  end

  # Only document examples marked as 'developer'
  config.define_group :developers do |config|
    config.filter = :developers
  end
end
```

## DSL

### Require the DSL

At the beginning of each acceptance/*_spec.rb file, make sure to require the following to pull in the DSL definitions:

```ruby
require 'rspec_api_documentation/dsl'
```


### Example Group Methods


#### resource

Create a set of documentation examples that go together. Acts as a describe block.

```ruby
resource "Orders" do
end
```

#### get, head, post, put, delete, patch

The method that will be sent along with the url.

```ruby
resource "Orders" do
  post "/orders" do
  end

  get "/orders" do
  end

  head "/orders" do
  end

  put "/orders/:id" do
    let(:id) { order.id }

    example "Get an order" do
      expect(path).to eq "/orders/1" # `:id` is replaced with the value of `id`
    end
  end

  delete "/orders/:id" do
  end

  patch "/orders/:id" do
  end
end
```

#### example

This is just RSpec's built in example method, we hook into the metadata surrounding it. `it` could also be used.

```ruby
resource "Orders" do
  post "/orders" do
    example "Creating an order" do
      do_request
      # make assertions
    end
  end
end
```

#### example_request

The same as example, except it calls `do_request` as the first step. Only assertions are required in the block.

Similar to `do_request` you can pass in a hash as the last parameter that will be passed along to `do_request` as extra parameters. These will _not_ become metadata like with `example`.

```ruby
resource "Orders" do
  parameter :name, "Order name"

  post "/orders" do
    example_request "Creating an order", :name => "Other name" do
      # make assertions
    end
  end
end
```

#### explanation

This method takes a string representing a detailed explanation of the example.

```ruby
resource "Orders" do
  post "/orders" do
    example "Creating an order" do
      explanation "This method creates a new order."
      do_request
      # make assertions
    end
  end
end
```

A resource can also have an explanation.

```ruby
resource "Orders" do
  explanation "Orders are top-level business objects. They can be created by a POST request"
  post "/orders" do
    example "Creating an order" do
      explanation "This method creates a new order."
      do_request
      # make assertions
    end
  end
end
```


#### header

This method takes the header name and value. The value can be a string or a symbol. If it is a symbol it will `send` the symbol, allowing you to `let` header values.

```ruby
resource "Orders" do
  header "Accept", "application/json"
  header "X-Custom", :custom_header

  let(:custom_header) { "dynamic" }

  get "/orders" do
    example_request "Headers" do
      expect(headers).to eq { "Accept" => "application/json", "X-Custom" => "dynamic" }
    end
  end
end
```

#### parameter

This method takes the parameter name, a description, and an optional hash of extra metadata that can be displayed in Raddocs as extra columns. If a method with the parameter name exists, e.g. a `let`, it will send the returned value up to the server as URL encoded data.

Special values:

* `:required => true` Will display a red '*' to show it's required
* `:scope => :the_scope` Will scope parameters in the hash, scoping can be nested. See example
* `:method => :method_name` Will use specified method as a parameter value

Retrieving of parameter value goes through several steps:
1. if `method` option is defined and test case responds to this method then this method is used;
2. if test case responds to scoped method then this method is used;
3. overwise unscoped method is used.

```ruby
resource "Orders" do
  parameter :auth_token, "Authentication Token"

  let(:auth_token) { user.authentication_token }

  post "/orders" do
    parameter :name, "Order Name", :required => true, :scope => :order
    parameter :item, "Order items", :scope => :order
    parameter :item_id, "Item id", :scope => [:order, :item], method: :custom_item_id

    let(:name) { "My Order" }
    # OR let(:order_name) { "My Order" }
    let(:item_id) { 1 }
    # OR let(:custom_item_id) { 1 }
    # OR let(:order_item_item_id) { 1 }

    example "Creating an order" do
      expect(params).to eq({
        :order => {
          :name => "My Order",
          :item => {
            :item_id => 1,
          }
        },
        :auth_token => auth_token,
      })
    end
  end
end
```

#### response_field

This method takes the response field name, a description, and an optional hash of extra metadata that can be displayed in Raddocs as extra columns.

Special values:
* `:scope => :the_scope` Will scope the response field in the hash

```ruby
resource "Orders" do
  response_field :page, "Current page"

  get "/orders" do
    example_request "Getting orders" do
      expect(response_body).to eq({ :page => 1 }.to_json)
    end
  end
end
```


You can also group metadata using [with_options](http://api.rubyonrails.org/classes/Object.html#method-i-with_options) to factor out duplications.

```ruby
resource "Orders" do
  post "/orders" do

    with_options :scope => :order, :required => true do
      parameter :name, "Order Name"
      parameter :item, "Order items"
    end

    with_options :scope => :order do
      response_field :id, "Order ID"
      response_field :status, "Order status"
    end

    let(:name) { "My Order" }
    let(:item_id) { 1 }

    example "Creating an order" do
      expect(status).to be 201
    end
  end
end
```

#### callback

This is complicated, see [relish docs](https://www.relishapp.com/zipmark/rspec-api-documentation/docs/document-callbacks).

#### trigger_callback

Pass this method a block which, when evaluated, will cause the application to make a request to `callback_url`.

### Example methods

#### callback_url

Defines the destination of the callback.

For an example, see [relish docs](https://www.relishapp.com/zipmark/rspec-api-documentation/docs/document-callbacks).

#### client

Returns the test client which makes requests and documents the responses.

```ruby
resource "Order" do
  get "/orders" do
    example "Listing orders" do
      # Create an order via the API instead of via factories
      client.post "/orders", order_hash

      do_request

      expect(status).to eq 200
    end
  end
end
```

#### do_callback

This will evaluate the block passed to `trigger_callback`, which should cause the application under test to make a callback request. See [relish docs](https://www.relishapp.com/zipmark/rspec-api-documentation/docs/document-callbacks).

#### do_request

Sends the request to the app with any parameters and headers defined.

```ruby
resource "Order" do
  get "/orders" do
    example "Listing orders" do
      do_request

      expect(status).to eq 200
    end
  end
end
```

#### no_doc

If you wish to make a request via the client that should not be included in your documentation, do it inside of a no_doc block.

```ruby
resource "Order" do
  get "/orders" do
    example "Listing orders" do
      no_doc do
        # Create an order via the API instead of via factories, don't document it
        client.post "/orders", order_hash
      end

      do_request

      expect(status).to eq 200
    end
  end
end
```

#### params

Get a hash of parameters that will be sent. See `parameter` documentation for an example.

#### header

This method takes the header name and value.

```ruby
resource "Orders" do
  before do
    header "Accept", "application/json"
  end

  get "/orders" do
    example_request "Headers" do
      expect(headers).to eq { "Accept" => "application/json" }
    end
  end
end
```

#### headers

This returns the headers that were sent as the request. See `header` documentation for an example.

#### response_body

Returns a string containing the response body from the previous request.

```ruby
resource "Order" do
  get "/orders" do
    example "Listing orders" do
      do_request

      expect(response_body).to eq [{ :name => "Order 1" }].to_json
    end
  end
end
```

#### response_headers

Returns a hash of the response headers from the previous request.

```ruby
resource "Order" do
  get "/orders" do
    example "Listing orders" do
      do_request

      expect(response_headers["Content-Type"]).to eq "application/json"
    end
  end
end
```

#### status, response_status

Returns the numeric status code from the response, eg. 200. `response_status` is an alias to status because status is commonly a parameter.

```ruby
resource "Order" do
  get "/orders" do
    example "Listing orders" do
      do_request

      expect(status).to eq 200
      expect(response_status).to eq 200
    end
  end
end
```

#### query_string

Data that will be sent as a query string instead of post data. Used in GET requests.

```ruby
resource "Orders" do
  parameter :name

  let(:name) { "My Order" }

  get "/orders" do
    example "List orders" do
      expect(query_string).to eq "name=My+Orders"
    end
  end
end
```

#### raw_post

You can completely override what gets sent as parameters by `let`-ing `raw_post`.

```ruby
resource "Orders" do
  header "Content-Type", "application/json"

  parameter :name

  let(:name) { "My Order" }

  post "/orders" do
    let(:raw_post) { params.to_json }

    example_request "Create new order" do
      # params get sent as JSON
    end
  end
end
```

## Rake Task

The gem contains a Railtie that defines a rake task for generating docs easily with Rails.
It loads all files in `spec/acceptance/**/*_spec.rb`.

```bash
$ rake docs:generate
```

If you are not using Rails, you can use Rake with the following Task:

```ruby
require 'rspec/core/rake_task'

desc 'Generate API request documentation from API specs'
RSpec::Core::RakeTask.new('docs:generate') do |t|
  t.pattern = 'spec/acceptance/**/*_spec.rb'
  t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter"]
end
```

or

```ruby
require 'rspec_api_documentation'
load 'tasks/docs.rake'
```

If you are not using Rake:

```bash
$ rspec spec/acceptance --format RspecApiDocumentation::ApiFormatter
```

## Uploading a file

For an example on uploading a file see `examples/spec/acceptance/upload_spec.rb`.

## Gotchas

- rspec_api_documentation relies on a variable `client` to be the test client. If you define your own `client` please configure rspec_api_documentation to use another one, see Configuration above.
- We make heavy use of RSpec metadata, you can actually use the entire gem without the DSL if you hand write the metadata.
- You must use `response_body`, `status`, `response_content_type`, etc. to access data from the last response. You will not be able to use `response.body` or `response.status` as the response object will not be created.
