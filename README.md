[![Travis status](https://secure.travis-ci.org/zipmark/rspec_api_documentation.png)](https://secure.travis-ci.org/zipmark/rspec_api_documentation)
[![Gemnasium status](https://gemnasium.com/zipmark/rspec_api_documentation.png)](https://gemnasium.com/zipmark/rspec_api_documentation)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/zipmark/rspec_api_documentation)

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
require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Orders" do
  get "/orders" do
    example "Listing orders" do
      do_request
      
      status.should == 200
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
    
#### spec/spec_helper.rb

```ruby
RspecApiDocumentation.configure do |config|
  config.format = :json
end
```

## Sample App

See the `example` folder for a sample Rails app that has been documented.


## Configuration options
```ruby
# Values listed are the default values
RspecApiDocumentation.configure do |config|
  # Set the application that Rack::Test uses
  config.app = Rails.application
  
  # Output folder
  config.docs_dir = Rails.root.join("doc", "api")
  
  # An array of output format(s).
  # Possible values are :json, :html, :combined_text, :combined_json,
  #   :json_iodocs, :textile, :append_json
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
end
```

## Format

* **json**: Generates an index file and example files in JSON.
* **html**: Generates an index file and example files in HTML.
* **combined_text**: Generates a single file for each resource. Used by [Raddocs](http://github.com/smartlogic/raddocs) for command line docs.
* **combined_json**: Generates a single file for all examples.
* **json_iodocs**: Generates [I/O Docs](http://www.mashery.com/product/io-docs) style documentation.
* **textile**: Generates an index file and example files in Textile.
* **append_json**: Lets you selectively run specs without destroying current documentation. See section below.

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
      status.should == 200
    end
    
    # Don't actually document this example, purely for testing purposes
    example "Get a list on page 2", :document => false do
      do_request(:page => 2)
      status.should == 404
    end
    
    # With example_request, you can't change the :document
    example_request "Get a list on page 3", :page => 3 do
      status.should == 404
    end
  end
  
  post "/accounts" do
    parameter :email, "User email"
    
    example "Creating an account", :document => :private do
      do_request(:email => "eric@example.com")
      status.should == 201
    end
    
    example "Creating an account - errors", :document => [:private, :developers] do
      do_request
      status.should == 422
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
      path.should == "/orders/1" # `:id` is replaced with the value of `id`
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

#### header

This method takes the header name and value. The value can be a string or a symbol. If it is a symbol it will `send` the symbol, allowing you to `let` header values.

```ruby
resource "Orders" do
  header "Accept", "application/json"
  header "X-Custom", :custom_header

  let(:custom_header) { "dynamic" }

  get "/orders" do
    example_request "Headers" do
      headers.should == { "Accept" => "application/json", "X-Custom" => "dynamic" }
    end
  end
end
```

#### parameter

This method takes the parameter name, a description, and an optional hash of extra metadata that can be displayed in Raddocs as extra columns. If a method with the parameter name exists, e.g. a `let`, it will send the returned value up to the server as URL encoded data. 

Special values:

* `:required => true` Will display a red '*' to show it's required
* `:scope => :the_scope` Will scope parameters in the hash. See example

```ruby
resource "Orders" do
  parameter :auth_token, "Authentication Token"

  let(:auth_token) { user.authentication_token }

  post "/orders" do
    parameter :name, "Order Name", :required => true, :scope => :order

    let(:name) { "My Order" }

    example "Creating an order" do
      params.should == { :order => { :name => "My Order" }, :auth_token => auth_token }
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

      status.should == 200
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

      status.should == 200
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

      status.should == 200
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
      headers.should == { "Accept" => "application/json" }
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

      response_body.should == [{ :name => "Order 1" }].to_json
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

      response_headers["Content-Type"].should == "application/json"
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

      status.should == 200
      response_status.should == 200
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
      query_string.should == "name=My+Orders"
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

## Gotchas

- rspec_api_documentation relies on a variable `client` to be the test client. If you define your own `client` please configure rspec_api_documentation to use another one, see Configuration above.
- We make heavy use of RSpec metadata, you can actually use the entire gem without the DSL if you hand write the metadata.
