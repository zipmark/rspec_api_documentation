require 'spec_helper'
require 'webmock/rspec'
require 'rack/test'

describe RspecApiDocumentation::TestServer do
  let(:test_server) { described_class.new(self) }

  subject { test_server }

  its(:session) { should equal(self) }
  its(:example) { should equal(example) }

  context "being called as a rack application" do
    include Rack::Test::Methods

    let(:app) { test_server }

    before { post "/path" }

    it "should expose the last request" do
      test_server.last_request.should equal(last_request)
    end

    it "should expose the last response" do
      test_server.last_response.should equal(last_response)
    end

    it "should always return 200" do
      last_response.status.should eq(200)
    end
  end
end
