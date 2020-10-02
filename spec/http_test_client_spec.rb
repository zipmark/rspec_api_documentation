require 'spec_helper'
require 'rack/test'
require 'capybara'
require 'capybara/server'
require 'sinatra/base'
require 'webmock/rspec'
require 'support/stub_app'

describe RspecApiDocumentation::HttpTestClient do
  before(:all) do
    WebMock.allow_net_connect!
    server = Capybara::Server.new(StubApp.new, 8888)
    server.boot
  end

  after(:all) do
    WebMock.disable_net_connect!
  end

  let(:client_context) { |example| double(example: example, app_root: 'nowhere') }
  let(:target_host) { 'http://localhost:8888' }
  let(:test_client) { RspecApiDocumentation::HttpTestClient.new(client_context, {host: target_host}) }

  subject { test_client }

  it { should be_a(RspecApiDocumentation::HttpTestClient) }

  its(:context) { should equal(client_context) }
  its(:example) { |example| should equal(example) }
  its(:metadata) { |example| should equal(example.metadata) }

  describe "xml data", :document => true do
    before do
      test_client.get "/xml"
    end

    it "should handle xml data" do
      expect(test_client.response_headers["Content-Type"]).to match(/application\/xml/)
    end

    it "should log the request" do |example|
      expect(example.metadata[:requests].first[:response_body]).to be_present
    end
  end

  describe "#query_string" do
    before do
      test_client.get "/?query_string=true"
    end

    it 'should contain the query_string' do
      expect(test_client.query_string).to eq("query_string=true")
    end
  end

  describe "#request_headers" do
    before do
      test_client.get "/", {}, { "Accept" => "application/json", "Content-Type" => "application/json", "User-Id" => "1" }
    end

    it "should contain all the headers" do
      expect(test_client.request_headers).to eq({
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "User-Id" => "1"
      })
    end
  end

  context "when doing request without parameter value" do
    before do
      test_client.post "/greet?query=&other=exists"
    end

    context "when examples should be documented", :document => true do
      it "should still argument the metadata" do |example|
        metadata = example.metadata[:requests].first
        expect(metadata[:request_query_parameters]).to eq({'query' => "", 'other' => 'exists'})
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
      it "should augment the metadata with information about the request" do |example|
        metadata = example.metadata[:requests].first
        expect(metadata[:request_method]).to eq("POST")
        expect(metadata[:request_path]).to eq("/greet?query=test+query")
        expect(metadata[:request_body]).to be_present
        expect(metadata[:request_headers]).to include({'Content-Type' => 'application/json;charset=utf-8'})
        expect(metadata[:request_headers]).to include({'X-Custom-Header' => 'custom header value'})
        expect(metadata[:request_query_parameters]).to eq({"query" => "test query"})
        expect(metadata[:request_content_type]).to match(/application\/json/)
        expect(metadata[:response_status]).to eq(200)
        expect(metadata[:response_body]).to be_present
        expect(metadata[:response_headers]['Content-Type']).to match(/application\/json/)
        expect(metadata[:response_headers]['Content-Length']).to eq('17')
        expect(metadata[:response_content_type]).to match(/application\/json/)
        expect(metadata[:curl]).to eq(RspecApiDocumentation::Curl.new("POST", "/greet?query=test+query", post_data, {"Content-Type" => "application/json;charset=utf-8", "X-Custom-Header" => "custom header value"}))
      end

      context "when post data is not json" do
        let(:post_data) { { :target => "nurse", :email => "email@example.com" } }
        let(:headers) { { "X-Custom-Header" => "custom header value" } }

        it "should not nil out request_body" do |example|
          body = example.metadata[:requests].first[:request_body]
          expect(body).to match(/target=nurse/)
          expect(body).to match(/email=email%40example\.com/)
        end
      end

      context "when post data is nil" do
        let(:post_data) { }

        it "should nil out request_body" do |example|
          expect(example.metadata[:requests].first[:request_body]).to be_nil
        end
      end
    end
  end

  context "formating response body", :document => true do
    after do
      RspecApiDocumentation.instance_variable_set(:@configuration, RspecApiDocumentation::Configuration.new)
    end

    before do
      RspecApiDocumentation.configure do |config|
        config.response_body_formatter =
          Proc.new do |_, response_body|
            response_body.upcase
          end
      end
      test_client.post "/greet?query=test+query", post_data, headers
    end

    let(:post_data) { { :target => "nurse" }.to_json }
    let(:headers) { { "Content-Type" => "application/json;charset=utf-8", "X-Custom-Header" => "custom header value" } }

    it "it formats the response_body based on the defined proc" do |example|
      metadata = example.metadata[:requests].first
      expect(metadata[:response_body]).to be_present
      expect(metadata[:response_body]).to eq '{"HELLO":"NURSE"}'
    end
  end
end
