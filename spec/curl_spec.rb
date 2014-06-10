require 'spec_helper'
describe RspecApiDocumentation::Curl do
  let(:host) { "http://example.com" }
  let(:curl) { RspecApiDocumentation::Curl.new(method, path, data, headers) }

  subject { curl.output(host, ["Host", "Cookies"]) }

  describe "POST" do
    let(:method) { "POST" }
    let(:path) { "/orders" }
    let(:data) { "order%5Bsize%5D=large&order%5Btype%5D=cart" }
    let(:headers) do
      {
        "HTTP_ACCEPT" => "application/json",
        "HTTP_X_HEADER" => "header",
        "HTTP_AUTHORIZATION" => %{Token token="mytoken"},
        "HTTP_HOST" => "example.org",
        "HTTP_COOKIES" => "",
        "HTTP_SERVER" => nil
      }
    end

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders/ }
    it { should =~ /-d 'order%5Bsize%5D=large&order%5Btype%5D=cart'/ }
    it { should =~ /-X POST/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }
    it { should =~ /-H "Authorization: Token token=\\"mytoken\\""/ }
    it { should =~ /-H "Server: "/ }
    it { should_not =~ /-H "Host: example\.org"/ }
    it { should_not =~ /-H "Cookies: "/ }

    it "should call post" do
      expect(curl).to receive(:post)
      curl.output(host)
    end
  end

  describe "GET" do
    let(:method) { "GET" }
    let(:path) { "/orders" }
    let(:data) { "size=large" }
    let(:headers) do
      {
        "HTTP_ACCEPT" => "application/json",
        "HTTP_X_HEADER" => "header",
        "HTTP_HOST" => "example.org",
        "HTTP_COOKIES" => ""
      }
    end

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders\?size=large/ }
    it { should =~ /-X GET/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }
    it { should_not =~ /-H "Host: example\.org"/ }
    it { should_not =~ /-H "Cookies: "/ }

    it "should call get" do
      expect(curl).to receive(:get)
      curl.output(host)
    end
  end

  describe "PUT" do
    let(:method) { "PUT" }
    let(:path) { "/orders/1" }
    let(:data) { "size=large" }
    let(:headers) do
      {
        "HTTP_ACCEPT" => "application/json",
        "HTTP_X_HEADER" => "header",
        "HTTP_HOST" => "example.org",
        "HTTP_COOKIES" => ""
      }
    end

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders\/1/ }
    it { should =~ /-d 'size=large'/ }
    it { should =~ /-X PUT/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }
    it { should_not =~ /-H "Host: example\.org"/ }
    it { should_not =~ /-H "Cookies: "/ }

    it "should call put" do
      expect(curl).to receive(:put)
      curl.output(host)
    end
  end

  describe "DELETE" do
    let(:method) { "DELETE" }
    let(:path) { "/orders/1" }
    let(:data) { }
    let(:headers) do
      {
        "HTTP_ACCEPT" => "application/json",
        "HTTP_X_HEADER" => "header",
        "HTTP_HOST" => "example.org",
        "HTTP_COOKIES" => ""
      }
    end

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders\/1/ }
    it { should =~ /-X DELETE/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }
    it { should_not =~ /-H "Host: example\.org"/ }
    it { should_not =~ /-H "Cookies: "/ }

    it "should call delete" do
      expect(curl).to receive(:delete)
      curl.output(host)
    end
  end

  describe "HEAD" do
    let(:method) { "HEAD" }
    let(:path) { "/orders" }
    let(:data) { "size=large" }
    let(:headers) do
      {
        "HTTP_ACCEPT" => "application/json",
        "HTTP_X_HEADER" => "header",
        "HTTP_HOST" => "example.org",
        "HTTP_COOKIES" => ""
      }
    end

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders\?size=large/ }
    it { should =~ /-X HEAD/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }
    it { should_not =~ /-H "Host: example\.org"/ }
    it { should_not =~ /-H "Cookies: "/ }

    it "should call get" do
      expect(curl).to receive(:head)
      curl.output(host)
    end
  end

  describe "PATCH" do
    let(:method) { "PATCH" }
    let(:path) { "/orders/1" }
    let(:data) { "size=large" }
    let(:headers) do
      {
        "HTTP_ACCEPT" => "application/json",
        "HTTP_X_HEADER" => "header",
        "HTTP_HOST" => "example.org",
        "HTTP_COOKIES" => ""
      }
    end

    it { should =~ /^curl/ }
    it { should =~ /http:\/\/example\.com\/orders\/1/ }
    it { should =~ /-d 'size=large'/ }
    it { should =~ /-X PATCH/ }
    it { should =~ /-H "Accept: application\/json"/ }
    it { should =~ /-H "X-Header: header"/ }
    it { should_not =~ /-H "Host: example\.org"/ }
    it { should_not =~ /-H "Cookies: "/ }

    it "should call put" do
      expect(curl).to receive(:patch)
      curl.output(host)
    end
  end

  describe "Basic Authentication" do
    let(:method) { "GET" }
    let(:path) { "/" }
    let(:data) { "" }
    let(:headers) do
      {
        "HTTP_AUTHORIZATION" => %{Basic dXNlckBleGFtcGxlLm9yZzpwYXNzd29yZA==},
      }
    end

    it { should_not =~ /-H "Authorization: Basic dXNlckBleGFtcGxlLm9yZzpwYXNzd29yZA=="/ }
    it { should =~ /-u user@example\.org:password/ }
  end
end
