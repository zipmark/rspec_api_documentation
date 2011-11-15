# RSpec API Doc Generator

Generate pretty API docs for your Rails APIs.

## Installation

Add rspec_api_documentation to your Gemfile

		gem 'rspec_api_documentation'

Bundle it!

		$> bundle install

## Usage

    resource "Account" do
      let(:app) { Rails.application }

      get "/accounts" do
        example "Get a list of all accounts" do
          do_request
          last_response.status.should be_ok
        end
      end

      get "/accounts/:id" do
        let(:account) { Factory(:account) }
        let(:id) { account.id }

        example "Get an account" do
          do_request
          last_response.status.should be_ok
        end
      end
    end
