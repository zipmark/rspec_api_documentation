# RSpec API Doc Generator

Generate pretty API docs for your Rails APIs.

## Installation

Add rspec_api_documentation to your Gemfile

		gem 'rspec_api_documentation'

Bundle it!
		
		$> bundle install

## Usage

	feature 'Account', :document => true, :resource_name => 'Account' do
		let(:client) {RspecApiDocumentation::TestClient.new}

		scenario 'Get all accounts' do
			client.get('/accounts')
		
			...
			your assertions
			...
		end
	end