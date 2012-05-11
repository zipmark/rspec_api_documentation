require 'spec_helper'
require 'webmock/rspec'
require 'rack/test'

describe RspecApiDocumentation::TestServer do
  let(:test_server) { described_class.new(self) }

  subject { test_server }

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

    it "should always return 200" do
      last_response.status.should eq(200)
    end

    context "when examples should be documentated", :document => true do
      it "should augment the metadata with information about the request" do
        metadata = example.metadata[:requests].first
        metadata[:request_method].should eq("POST")
        metadata[:request_body].should eq(body)
        metadata[:request_headers].should == {"Content-Type" => "application/json", "X-Custom-Header" => "custom header value", "Host" => "example.org", "Cookie" => ""}
      end
    end
  end
end
