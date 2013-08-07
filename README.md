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

### Raddocs

Also consider adding [Raddocs](http://github.com/smartlogic/raddocs/) as a viewer. It has much better HTML output than
rspec_api_documentation.

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
  
  # An array of output format(s). Possible values are :json, :html
  config.format = [:html]
  
  # Location of templates
  config.template_path = "inside of the gem"
  
  # Filter by example document type
  config.filter = :all
  
  # Filter by example document type
  config.exclusion_filter = nil
  
  # Used when adding a cURL output to the docs
  config.curl_host = nil
  
  # By default examples and resources are ordered by description. Set to true keep
  # the source order.
  config.keep_source_order = false
  
  # Change the name of the API on index pages
  config.api_name = "API Documentation"
  
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

#### get, post, put, delete

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

## Gotchas

- rspec_api_documentation relies on a variable `client` to be the test client. Make sure you don't redefine this variable.
- We make heavy use of RSpec metadata, you can actually use the entire gem without the DSL if you hand write the metadata.

## Usage

```ruby
resource "Account" do
  get "/accounts" do
    parameter :order, "Order of accounts"

    example_request "Get a list of all accounts" do
      status.should == 200
    end

    example "Get a list of all accounts in reverse order" do
      do_request(:order => "reverse")

      response_body.should == accounts.reverse
      status.should == 200
    end
  end

  get "/accounts/:id" do
    let(:account) { Factory(:account) }
    let(:id) { account.id }

    example "Get an account", :document => :public do
      do_request

      status.should == 200
    end
  end
end
```

