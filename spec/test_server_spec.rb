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
    let(:method) { :post }
    let(:path) { "/path" }
    let(:body) { {:foo => "bar", :baz => "quux"}.to_json }
    let(:headers) {{
      "Content-Type" => "application/json",
      "X-Custom-Header" => "custom header value"
    }}

    before {
      headers.each { |k, v| header k, v }
      send(method, path, body)
    }

    it "should expose the last request" do
      test_server.last_request.should equal(last_request)
    end

    it "should expose the last response" do
      test_server.last_response.should equal(last_response)
    end

    it "should always return 200" do
      last_response.status.should eq(200)
    end

    context "when examples should be documentated", :document => true do
      it "should augment the metadata with information about the request" do
        example.metadata[:public].should be_false
        example.metadata[:method].should eq("POST")
        example.metadata[:route].should eq(path)
        example.metadata[:request_body].should eq("{\n  \"foo\": \"bar\",\n  \"baz\": \"quux\"\n}")
        example.metadata[:request_headers].should eq("Content-Type: application/json\nX-Custom-Header: custom header value\nHost: example.org\nCookie: ")
      end
    end

    context "when examples should be publicly documented", :document => :public do
      it "should augment the metadata to indicate public" do
        example.metadata[:public].should be_true
      end
    end

    context "when examples should not be documented", :document => false do
      it "should not augment the metadata" do
        example.metadata[:public].should be_false
      end
    end
  end
end
