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

## Sample App

See the `example` folder for a sample Rails app that has been documented.


## Configuration options
- app - Set the application that Rack::Test uses, defaults to `Rails.application`
- docs_dir - Output folder
- format - An array of output format(s). Possible values are :json, :html, or :wurl. The final option is similar to :html, but includes the wURL console.
- template_path - Location of templates
- filter - Filter by example document type
- exclusion_filter - Filter by example document type
- url_prefix - Add before all links on the index page, useful if docs are located in `public/docs`, must include a leading `/`, no trailing `/`; eg `/docs`
- curl_host - Used when adding a cURL output to the docs
- keep_source_order - By default examples and resources are ordered by description. Set to true keep the source order.
- api_name - Change the name of the API on index pages, default is "API Documentation"

### Example Configuration
`spec/spec_helper.rb`

```ruby
RspecApiDocumentation.configure do |config|
  config.docs_dir = Rails.root.join("app", "views", "pages")

  config.define_group :public do |config|
    config.docs_dir = Rails.root.join("public", "docs")
    config.url_prefix = "/docs"
  end
end
```

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

