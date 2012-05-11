require "spec_helper"

module DSL2
  extend ActiveSupport::Concern

  module ClassMethods
    def post(request_path, title, &block)
      define_method(:http_method) { "POST" }
      context = context(title) do
        let(:request_path) { request_path }
        instance_eval(&block)
      end
    end

    def resource
      metadata[:resource]
    end
  end

  def status
    client.get "/orders"
    client.status
  end

  def client
    @client ||= RspecApiDocumentation::RackTestClient.new(self)
  end

  def app
    RspecApiDocumentation.configuration.app
  end
end

RspecApiDocumentation.configuration.app = lambda do |env|
  [200, {}, [""]]
end

describe "Orders" do
  include DSL2

  let(:resource) { example.metadata[:resource] }

  post "/orders", "Make an order" do
    it "records the http method" do
      http_method.should == "POST"
    end

    it "records the request path" do
      request_path.should == "/orders"
    end

    it "records the response status" do
      status.should == 200
    end
  end
end
