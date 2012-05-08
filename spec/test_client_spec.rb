require 'spec_helper'
require 'rack/test'
require 'sinatra/base'

class StubApp < Sinatra::Base
  get "/" do
    content_type :json

    { :hello => "world" }.to_json
  end

  post "/greet" do
    content_type :json

    request.body.rewind
    begin
      data = JSON.parse request.body.read
    rescue JSON::ParserError
      request.body.rewind
      data = request.body.read
    end
    { :hello => data["target"] }.to_json
  end

  get "/xml" do
    content_type :xml

    "<hello>World</hello>"
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

  describe "xml data", :document => true do
    before do
      test_client.get "/xml"
    end

    it "should handle xml data" do
      test_client.last_response.headers["Content-Type"].should =~ /application\/xml/
    end

    it "should log the request" do
      example.metadata[:requests].first[:response_body].should be_present
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

  describe "setup default headers" do
    it "should let you set default headers when creating a new TestClient" do
      test_client = RspecApiDocumentation::TestClient.new(self, :headers => { "HTTP_MY_HEADER" => "hello" })
      test_client.get "/"
      test_client.last_headers["HTTP_MY_HEADER"].should == "hello"
      test_client.last_headers.should have(3).headers
    end

    it "should be blank if not set" do
      test_client = RspecApiDocumentation::TestClient.new(self)
      test_client.get "/"
      test_client.last_headers.should have(2).headers
    end
  end

  context "after a request is made" do
    before do
      header "Content-Type", "application/json;charset=utf-8"
      header "X-Custom-Header", "custom header value"
      test_client.post "/greet?query=test+query", post_data
    end

    let(:post_data) { { :target => "nurse" }.to_json }

    context "when examples should be documented", :document => true do
      it "should augment the metadata with information about the request" do
        metadata = example.metadata[:requests].first
        metadata[:method].should eq("POST")
        metadata[:route].should eq("/greet")
        metadata[:query_string].should eq("?query=test+query")
        metadata[:request_body].should be_present
        metadata[:request_headers].should include({'Content-Type' => 'application/json;charset=utf-8'})
        metadata[:request_headers].should include({'X-Custom-Header' => 'custom header value'})
        metadata[:request_query_parameters].should == {"query" => "test+query"}
        metadata[:response_status].should eq(200)
        metadata[:response_body].should be_present
        metadata[:response_headers]["Content-Type"].should =~ /application\/json/
        metadata[:response_headers]["Content-Length"].should == "17"
        metadata[:curl].should eq(RspecApiDocumentation::Curl.new("post", "/greet?query=test+query", post_data, {"CONTENT_TYPE" => "application/json;charset=utf-8", "HTTP_X_CUSTOM_HEADER" => "custom header value", "HTTP_HOST" => "example.org", "HTTP_COOKIE" => ""}))
      end

      context "when post data is not json" do
        let(:post_data) { { :target => "nurse", :email => "email@example.com" } }

        it "should not nil out request_body" do
          body = example.metadata[:requests].first[:request_body]
          body.should =~ /target=nurse/
          body.should =~ /email=email%40example\.com/
        end
      end

      context "when post data is nil" do
        let(:post_data) { }

        it "should not nil out request_body" do
          example.metadata[:requests].first[:request_body].should eq(nil)
        end
      end
    end
  end
end
