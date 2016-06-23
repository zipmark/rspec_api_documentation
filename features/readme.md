[![Travis status](https://secure.travis-ci.org/zipmark/rspec_api_documentation.png)](https://secure.travis-ci.org/zipmark/rspec_api_documentation)
[![Gemnasium status](https://gemnasium.com/zipmark/rspec_api_documentation.png)](https://gemnasium.com/zipmark/rspec_api_documentation)

http://github.com/zipmark/rspec_api_documentation

# RSpec API Doc Generator

Generate pretty API docs for your Rails APIs.

## Installation

Add rspec_api_documentation to your Gemfile

    gem 'rspec_api_documentation'

Bundle it!

    $> bundle install

Require it in your API tests

    require "rspec_api_documentation"
    require "rspec_api_documentation/dsl"

See the wiki for additional setup. [Setting up RSpec API Documentation](https://github.com/zipmark/rspec_api_documentation/wiki/Setting-up-RspecApiDocumentation)

## Usage

    resource "Account" do
      get "/accounts" do
        example "Get a list of all accounts" do
          do_request
          expect(last_response.status).to be_ok
        end
      end

      get "/accounts/:id" do
        parameter :id, "Account ID"

        let(:account) { Factory(:account) }
        let(:id) { account.id }

        example "Get an account", :document => :public do
          do_request
          expect(last_response.status).to be_ok
        end
      end
    end

