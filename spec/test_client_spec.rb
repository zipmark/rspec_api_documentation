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
  let(:context) { stub(:app => StubApp, :example => example) }
  let(:test_client) { RspecApiDocumentation::TestClient.new(context, {}) }

  subject { test_client }

  it { should be_a(RspecApiDocumentation::TestClient) }

  its(:context) { should equal(context) }
  its(:example) { should equal(example) }
  its(:metadata) { should equal(example.metadata) }

  describe "xml data", :document => true do
    before do
      test_client.get "/xml"
    end

    it "should handle xml data" do
      test_client.last_response_headers["Content-Type"].should =~ /application\/xml/
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

  describe "#last_request_headers" do
    before do
      test_client.options[:headers] = {
        "HTTP_ACCEPT" => "application/json",
        "CONTENT_TYPE" => "application/json"
      }
      test_client.get "/"
    end

    it "should contain all the headers" do
      test_client.last_request_headers.should eq({
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "Host" => "example.org",
        "Cookie" => ""
      })
    end
  end

  describe "#headers" do
    before do
      test_client.options[:headers] = { "HTTP_X_CUSTOM_HEADER" => "custom header value" }
      test_client.get "/"
    end

    it "can be overridden to add headers to the request" do
      test_client.last_request_headers["X-Custom-Header"].should eq("custom header value")
    end
  end

  describe "setup default headers" do
    it "should let you set default headers when creating a new TestClient" do
      test_client = RspecApiDocumentation::TestClient.new(context, :headers => { "HTTP_MY_HEADER" => "hello" })
      test_client.get "/"
      test_client.last_request_headers["My-Header"].should == "hello"
      test_client.last_request_headers.should have(3).headers
    end

    it "should be blank if not set" do
      test_client = RspecApiDocumentation::TestClient.new(context)
      test_client.get "/"
      test_client.last_request_headers.should have(2).headers
    end
  end

  context "after a request is made" do
    before do
      test_client.options[:headers] = {
        "CONTENT_TYPE" => "application/json;charset=utf-8",
        "HTTP_X_CUSTOM_HEADER" => "custom header value"
      }
      test_client.post "/greet?query=test+query", post_data
    end

    let(:post_data) { { :target => "nurse" }.to_json }

    context "when examples should be documented", :document => true do
      it "should augment the metadata with information about the request" do
        metadata = example.metadata[:requests].first
        metadata[:request_method].should eq("POST")
        metadata[:request_path].should eq("/greet?query=test+query")
        metadata[:request_body].should be_present
        metadata[:request_headers].should match(/^Content-Type: application\/json/)
        metadata[:request_headers].should match(/^X-Custom-Header: custom header value$/)
        metadata[:request_query_parameters].should eq("query: test query")
        metadata[:response_status].should eq(200)
        metadata[:response_status_text].should eq("OK")
        metadata[:response_body].should be_present
        metadata[:response_headers].should match(/^Content-Type: application\/json/)
        metadata[:response_headers].should match(/^Content-Length: 17$/)
        metadata[:curl].should eq(RspecApiDocumentation::Curl.new("post", "/greet?query=test+query", post_data, {"Content-Type" => "application/json;charset=utf-8", "X-Custom-Header" => "custom header value", "Host" => "example.org", "Cookie" => ""}))
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
