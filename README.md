# RSpec API Doc Generator

Generate pretty API docs for your Rails APIs.

## Installation

Add rspec_api_documentation to your Gemfile

    gem 'rspec_api_documentation'

Bundle it!

    $> bundle install

## Sample App

See the `example` folder for a sample Rails app that has been documented.


## Configuration options
- app - Set the application that Rack::Test uses, defaults to `Rails.application`
- docs_dir - Output folder
- format - Output format
- template_path - Location of templates
- filter - Filter by example document type
- exclusion_filter - Filter by example document type

### Example Configuration
`spec/spec_helper.rb`

    RspecApiDocumentation.configure do |config|
      config.docs_dir = Rails.root.join("app", "views", "pages")

      config.define_group :public do |config|
        config.docs_dir = Rails.root.join("public", "docs")
      end
    end

## Usage

    resource "Account" do
      get "/accounts" do
        example "Get a list of all accounts" do
          do_request
          last_response.status.should be_ok
        end
      end

      get "/accounts/:id" do
        parameter :id, "Account ID"

        let(:account) { Factory(:account) }
        let(:id) { account.id }

        example "Get an account", :document => :public do
          do_request
          last_response.status.should be_ok
        end
      end
    end

