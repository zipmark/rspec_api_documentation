require 'spec_helper'
require 'rack/test'

describe RspecApiDocumentation::HttpTestClient do
  before(:all) do
      WebMock.allow_net_connect!

      $external_test_app_pid = spawn("ruby ./spec/support/external_test_app.rb")
      Process.detach $external_test_app_pid
      sleep 3 #Wait until the test app is up
  end

  after(:all) do
    WebMock.disable_net_connect!

    Process.kill('TERM', $external_test_app_pid)
  end

  let(:client_context) { double(example: example, app_root: 'nowhere') }
  let(:target_host) { 'http://localhost:4567' }
  let(:test_client) { RspecApiDocumentation::HttpTestClient.new(client_context, {host: target_host}) }

  subject { test_client }

  it { should be_a(RspecApiDocumentation::HttpTestClient) }

  its(:context) { should equal(client_context) }
  its(:example) { should equal(example) }
  its(:metadata) { should equal(example.metadata) }

  describe "xml data", :document => true do
    before do
      test_client.get "/xml"
    end

    it "should handle xml data" do
      test_client.response_headers["Content-Type"].should =~ /application\/xml/
    end

    it "should log the request" do
      example.metadata[:requests].first[:response_body].should be_present
    end
  end

  describe "#query_string" do
    before do
      test_client.get "/?query_string=true"
    end

    it 'should contain the query_string' do
      test_client.query_string.should == "query_string=true"
    end
  end

  describe "#request_headers" do
    before do
      test_client.get "/", {}, { "Accept" => "application/json", "Content-Type" => "application/json" }
    end

    it "should contain all the headers" do
      test_client.request_headers.should eq({
        "Accept" => "application/json",
        "Content-Type" => "application/json"
      })
    end
  end

  context "when doing request without parameter value" do
    before do
      test_client.post "/greet?query=&other=exists"
    end

    context "when examples should be documented", :document => true do
      it "should still argument the metadata" do
        metadata = example.metadata[:requests].first
        metadata[:request_query_parameters].should == {'query' => "", 'other' => 'exists'}
      end
    end
  end

  context "after a request is made" do
    before do
      test_client.post "/greet?query=test+query", post_data, headers
    end

    let(:post_data) { { :target => "nurse" }.to_json }
    let(:headers) { { "Content-Type" => "application/json;charset=utf-8", "X-Custom-Header" => "custom header value" } }

    context "when examples should be documented", :document => true do
      it "should augment the metadata with information about the request" do
        metadata = example.metadata[:requests].first
        metadata[:request_method].should eq("POST")
        metadata[:request_path].should eq("/greet?query=test+query")
        metadata[:request_body].should be_present
        metadata[:request_headers].should include({'CONTENT_TYPE' => 'application/json;charset=utf-8'})
        metadata[:request_headers].should include({'HTTP_X_CUSTOM_HEADER' => 'custom header value'})
        metadata[:request_query_parameters].should == {"query" => "test query"}
        metadata[:request_content_type].should match(/application\/json/)
        metadata[:response_status].should eq(200)
        metadata[:response_body].should be_present
        metadata[:response_headers]['Content-Type'].should match(/application\/json/)
        metadata[:response_headers]['Content-Length'].should == '18'
        metadata[:response_content_type].should match(/application\/json/)
        metadata[:curl].should eq(RspecApiDocumentation::Curl.new("POST", "/greet?query=test+query", post_data, {"Content-Type" => "application/json;charset=utf-8", "X-Custom-Header" => "custom header value"}))
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

        it "should nil out request_body" do
          example.metadata[:requests].first[:request_body].should be_nil
        end
      end
    end
  end
end
