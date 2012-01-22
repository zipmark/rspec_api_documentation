require 'spec_helper'
describe RspecApiDocumentation::Curl do
  let(:host) { "http://example.com" }
  let(:curl) { RspecApiDocumentation::Curl.new(method, host, path, data, headers) }

  subject { curl.output }

  describe "POST" do
    let(:method) { "POST" }
    let(:path) { "/orders" }
    let(:data) { { :order => { :size => "large", :type => "cart" } } }
    let(:headers) { {"HTTP_ACCEPT" => "application/json", "HTTP_X_HEADER" => "header"} }

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders/ }
    it { should =~ /-d "order%5Bsize%5D=large"/ }
    it { should =~ /-d "order%5Btype%5D=cart"/ }
    it { should =~ /-X POST/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }

    it "should call post" do
      curl.should_receive(:post)
      curl.output
    end
  end

  describe "GET" do
    let(:method) { "GET" }
    let(:path) { "/orders" }
    let(:data) { { :size => "large" } }
    let(:headers) { {"HTTP_ACCEPT" => "application/json", "HTTP_X_HEADER" => "header"} }

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders\?size=large/ }
    it { should =~ /-X GET/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }

    it "should call get" do
      curl.should_receive(:get)
      curl.output
    end
  end

  describe "PUT" do
    let(:method) { "PUT" }
    let(:path) { "/orders/1" }
    let(:data) { { :size => "large" } }
    let(:headers) { {"HTTP_ACCEPT" => "application/json", "HTTP_X_HEADER" => "header"} }

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders\/1/ }
    it { should =~ /-d "size=large"/ }
    it { should =~ /-X PUT/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }

    it "should call put" do
      curl.should_receive(:put)
      curl.output
    end
  end

  describe "DELETE" do
    let(:method) { "DELETE" }
    let(:path) { "/orders/1" }
    let(:data) { }
    let(:headers) { {"HTTP_ACCEPT" => "application/json", "HTTP_X_HEADER" => "header"} }

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders\/1/ }
    it { should =~ /-X DELETE/ }

    it "should call delete" do
      curl.should_receive(:delete)
      curl.output
    end
  end
end
