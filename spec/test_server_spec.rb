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
        metadata = example.metadata[:requests].first
        metadata[:method].should eq("POST")
        metadata[:route].should eq(path)
        metadata[:request_body].should eq(JSON.pretty_generate(JSON.parse(body)))
        metadata[:request_headers].split("\n").sort.should eq("Content-Type: application/json\nX-Custom-Header: custom header value\nHost: example.org\nCookie: ".split("\n").sort)
      end
    end
  end
end
