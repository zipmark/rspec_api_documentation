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

    $> bundle install

See the wiki for additional setup. [Setting up RSpec API Documentation](https://github.com/zipmark/rspec_api_documentation/wiki/Setting-up-RspecApiDocumentation)

### Raddocs

Also consider adding [Raddocs](http://github.com/smartlogic/raddocs/) as a viewer. It has much better HTML output than
rspec_api_documentation.

    gem 'raddocs'

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

