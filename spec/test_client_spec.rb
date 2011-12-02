require 'spec_helper'
require 'rack/test'
require 'sinatra/base'

class StubApp < Sinatra::Base
  before do
    content_type :json
  end

  get "/" do
    { :hello => "world" }.to_json
  end

  post "/greet" do
    request.body.rewind
    data = JSON.parse request.body.read
    { :hello => data["target"] }.to_json
  end
end

describe RspecApiDocumentation::TestClient do
  include Rack::Test::Methods

  let(:app) { StubApp }
  let(:test_client) { RspecApiDocumentation::TestClient.new(self) }

  subject { test_client }

  it { should be_a(RspecApiDocumentation::TestClient) }

  its(:session) { should equal(self) }
  its(:example) { should equal(example) }
  its(:metadata) { should equal(example.metadata) }

  describe "#last_response" do
    before do
      test_client.get "/"
    end

    it "should expose the last request" do
      test_client.last_request.should equal(last_request)
    end

    it "should expose the last response" do
      test_client.last_response.should equal(last_response)
    end
  end

  describe "#last_query_string" do
    before do
      test_client.get "/?query_string=true"
    end

    it 'should contain the query_string' do
      test_client.last_query_string.should == "query_string=true"
    end
  end

  describe "#last_query_hash" do
    before do
      test_client.get "/?query_hash=true"
    end

    it 'should contain the query_hash' do
      test_client.last_query_hash.should == { "query_hash" => "true" }
    end
  end

  describe "#last_headers" do
    before do
      header "Accept", "application/json"
      header "Content-Type", "application/json"

      test_client.get "/"
    end

    it "should contain all the headers" do
      test_client.last_headers.should eq({
        "HTTP_ACCEPT" => "application/json",
        "CONTENT_TYPE" => "application/json",
        "HTTP_HOST" => "example.org",
        "HTTP_COOKIE" => ""
      })
    end
  end

  describe "#headers" do
    before do
      test_client.stub!(:headers).and_return({"HTTP_X_CUSTOM_HEADER" => "custom header value"})
      test_client.get "/"
    end

    it "can be overridden to add headers to the request" do
      test_client.last_headers["HTTP_X_CUSTOM_HEADER"].should eq("custom header value")
    end
  end

  context "after a request is made" do
    before do
      header "Content-Type", "application/json"
      header "X-Custom-Header", "custom header value"
      test_client.post "/greet?test_query=true", { :target => "nurse" }.to_json
    end

    context "when examples should be documented", :document => true do
      it "should augment the metadata with information about the request" do
        example.metadata[:public].should be_false
        example.metadata[:method].should eq("POST")
        example.metadata[:route].should eq("/greet?test_query=true")
        example.metadata[:request_body].should eq("{\n  \"target\": \"nurse\"\n}")
        example.metadata[:request_headers].should eq("Content-Type: application/json\nX-Custom-Header: custom header value\nHost: example.org\nCookie: ")
        example.metadata[:request_query_parameters].should eq("test_query: true")
        example.metadata[:response_status].should eq(200)
        example.metadata[:response_status_text].should eq("OK")
        example.metadata[:response_body].should eq("{\n  \"hello\": \"nurse\"\n}")
        example.metadata[:response_headers].should eq("Content-Type: application/json\nContent-Length: 17")
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
