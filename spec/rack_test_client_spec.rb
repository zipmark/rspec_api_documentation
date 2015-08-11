require 'spec_helper'
require 'rack/test'
require 'sinatra/base'
require 'support/stub_app'

describe RspecApiDocumentation::RackTestClient do
  let(:context) { |example| double(:app => StubApp, :example => example) }
  let(:test_client) { RspecApiDocumentation::RackTestClient.new(context, {}) }

  subject { test_client }

  it { expect(subject).to be_a(RspecApiDocumentation::RackTestClient) }

  its(:context) { should equal(context) }
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
      test_client.get "/", {}, { "Accept" => "application/json", "Content-Type" => "application/json" }
    end

    it "should contain all the headers" do
      expect(test_client.request_headers).to eq({
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "Host" => "example.org",
        "Cookie" => ""
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
        expect(metadata[:curl]).to eq(RspecApiDocumentation::Curl.new("POST", "/greet?query=test+query", post_data, {"Content-Type" => "application/json;charset=utf-8", "X-Custom-Header" => "custom header value", "Host" => "example.org", "Cookie" => ""}))
      end

      specify "fetching binary data" do |example|
        test_client.get "/binary"
        metadata = example.metadata[:requests].last
        expect(metadata[:response_body]).to eq("[binary data]")
      end

      specify "fetching json data" do |example|
        metadata = example.metadata[:requests].first
        expect(metadata[:response_body]).to eq(JSON.pretty_generate({
          :hello => "nurse",
        }))
      end

      context "when post data is not json" do
        let(:post_data) { { :target => "nurse", :email => "email@example.com" } }

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

      specify "array parameters" do |example|
        test_client.post "/greet?query[]=test&query[]=query", post_data, headers

        metadata = example.metadata[:requests].last
        expect(metadata[:request_query_parameters]).to eq({ "query" => ["test", "query"] })
      end
    end
  end
end
