[![Travis status](https://secure.travis-ci.org/zipmark/rspec_api_documentation.png)](https://secure.travis-ci.org/zipmark/rspec_api_documentation)
[![Gemnasium status](https://gemnasium.com/zipmark/rspec_api_documentation.png)](https://gemnasium.com/zipmark/rspec_api_documentation)

# RSpec API Doc Generator

Generate pretty API docs for your Rails APIs.

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
- format - Output format
- template_path - Location of templates
- filter - Filter by example document type
- exclusion_filter - Filter by example document type
- url_prefix - Add before all links on the index page, useful if docs are located in `public/docs`
- keep_source_order - By default examples and resources are ordered by description. Set to true keep the source order.

### Example Configuration
`spec/spec_helper.rb`

    RspecApiDocumentation.configure do |config|
      config.docs_dir = Rails.root.join("app", "views", "pages")

      config.define_group :public do |config|
        config.docs_dir = Rails.root.join("public", "docs")
        config.url_prefix = "docs/"
      end
    end

## Usage

    resource "Account" do
      get "/accounts" do
        example "Get a list of all accounts" do
          do_request
          status.should be_ok
        end
      end

      get "/accounts/:id" do
        parameter :id, "Account ID"

        let(:account) { Factory(:account) }
        let(:id) { account.id }

        example "Get an account", :document => :public do
          do_request
          status.should be_ok
        end
      end
    end

