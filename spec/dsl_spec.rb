require 'spec_helper'
require 'rspec_api_documentation/dsl'
require 'net/http'
require "rack/test"

describe "Non-api documentation specs" do
  it "should not be polluted by the rspec api dsl" do |example|
    expect(example.example_group).to_not include(RspecApiDocumentation::DSL)
  end
end

resource "Order" do
  explanation "Order resource explanation"

  describe "example metadata" do
    subject { |example| example.metadata }

    its([:resource_name]) { should eq("Order") }
    its([:resource_explanation]) { should eq("Order resource explanation") }
    its([:document]) { should be_truthy }
  end

  describe "example context" do
    it "should provide a client" do
      expect(client).to be_a(RspecApiDocumentation::RackTestClient)
    end

    it "should return the same client every time" do
      expect(client).to equal(client)
    end
  end

  [:post, :get, :put, :delete, :head, :patch].each do |http_method|
    send(http_method, "/path") do
      specify { |example| expect(example.example_group.description).to eq("#{http_method.to_s.upcase} /path") }

      describe "example metadata" do
        subject { |example| example.metadata }

        its([:method]) { should eq(http_method) }
        its([:route]) { should eq("/path") }
      end

      describe "example context" do
        subject { self }

        its(:method) { should eq(http_method) }
        its(:path) { should eq("/path") }

        describe "do_request" do
          it "should call the correct method on the client" do
            expect(client).to receive(http_method)
            do_request
          end
        end
      end
    end
  end

  post "/orders" do
    parameter :type, "The type of drink you want.", :required => true
    parameter :size, "The size of drink you want.", :required => true
    parameter :note, "Any additional notes about your order.", method: :custom_note
    parameter :name, :scope => :order, method: :custom_order_name
    parameter :quantity, "The quantity of drinks you want.", value: '3'

    response_field :type, "The type of drink you ordered.", :scope => :order
    response_field :size, "The size of drink you ordered.", :scope => :order
    response_field :note, "Any additional notes about your order.", :scope => :order
    response_field :name, :scope => :order
    response_field :id, "The order id"

    let(:type) { "coffee" }
    let(:size) { "medium" }

    let(:note) { "Made in Brazil" }
    let(:custom_note) { "Made in India" }

    let(:order_name) { "Nescoffee" }
    let(:custom_order_name) { "Jakobz" }

    describe "example metadata" do
      subject { |example| example.metadata }

      it "should include the documentated parameters" do
        expect(subject[:parameters]).to eq(
          [
            { :name => "type", :description => "The type of drink you want.", :required => true },
            { :name => "size", :description => "The size of drink you want.", :required => true },
            { :name => "note", :description => "Any additional notes about your order.", method: :custom_note },
            { :name => "name", :description => "Order name", :scope => :order, method: :custom_order_name },
            { :name => "quantity", :description => "The quantity of drinks you want.", value: '3' }
          ]
        )
      end

      it "should include the documentated response fields" do
        expect(subject[:response_fields]).to eq (
          [
            { :name => "type", :description => "The type of drink you ordered.", :scope => :order },
            { :name => "size", :description => "The size of drink you ordered.", :scope => :order },
            { :name => "note", :description => "Any additional notes about your order.", :scope => :order },
            { :name => "name", :description => "Order name", :scope => :order },
            { :name => "id", :description => "The order id" },
          ]
        )
      end
    end

    describe "example context" do
      subject { self }

      describe "params" do
        it "should equal the assigned parameter values" do
          expect(params).to eq({
            "type" => "coffee",
            "size" => "medium",
            "note" => "Made in India",
            "order" => { "name" => "Jakobz" },
            "quantity" => "3"
          })
        end
      end
    end
  end

  put "/orders/:id" do
    parameter :type, "The type of drink you want.", :required => true
    parameter :size, "The size of drink you want.", :required => true
    parameter :id, 'The ID of the resource.', :required => true, scope: :data
    parameter :note, "Any additional notes about your order."

    let(:type) { "coffee" }
    let(:size) { "medium" }
    let(:data_id) { 2 }

    let(:id) { 1 }

    describe "do_request" do
      context "when raw_post is defined" do
        let(:raw_post) { { :bill => params }.to_json }

        it "should send the raw post body" do
          expect(client).to receive(method).with(path, raw_post, nil)
          do_request
        end
      end

      context "when raw_post is not defined" do
        it "should send the params hash" do
          expect(client).to receive(method).with(path, params, nil)
          do_request
        end
      end

      it 'should set the scoped data ID' do
        expect(params['data']).to eq({'id' => 2})
      end

      it "should allow extra parameters to be passed in" do
        expect(client).to receive(method).with(path, params.merge("extra" => true), nil)
        do_request(:extra => true)
      end

      it "should overwrite parameters" do
        expect(client).to receive(method).with(path, params.merge("size" => "large"), nil)
        do_request(:size => "large")
      end

      it "should overwrite path variables" do
        expect(client).to receive(method).with("/orders/2", params, nil)
        do_request(:id => 2)
      end
    end

    describe "no_doc" do
      it "should not add requests" do |example|
        example.metadata[:requests] = ["first request"]

        no_doc do
          expect(example.metadata[:requests]).to be_empty
          example.metadata[:requests] = ["not documented"]
        end

        expect(example.metadata[:requests]).to eq(["first request"])
      end
    end
  end

  put "/orders/{id}" do
    describe "url params with curly braces" do
      it "should overwrite path variables" do
        expect(client).to receive(method).with("/orders/2", params, nil)
        do_request(:id => 2)
      end
    end
  end

  get "/orders/:order_id/line_items/:id" do
    parameter :type, "The type document you want"

    describe "do_request" do
      it "should correctly set path variables and other parameters" do
        expect(client).to receive(method).with("/orders/3/line_items/2?type=short", nil, nil)
        do_request(:id => 2, :order_id => 3, :type => 'short')
      end
    end
  end

  get "/orders/{order_id}/line_items/{id}" do
    describe "url params with curly braces" do
      it "should overwrite path variables and other parameters" do
        expect(client).to receive(method).with("/orders/3/line_items/2?type=short", nil, nil)
        do_request(:id => 2, :order_id => 3, :type => 'short')
      end
    end
  end

  get "/orders/:order_id" do
    let(:order) { double(:id => 1) }

    describe "path" do
      subject { self.path }

      context "when id has been defined" do
        let(:order_id) { order.id }

        it "should have the value of id subtituted for :id" do
          expect(subject).to eq("/orders/1")
        end
      end

      context "when id has not been defined" do
        it "should be unchanged" do
          expect(subject).to eq("/orders/%3Aorder_id")
        end
      end
    end
  end

  describe "nested parameters" do
    parameter :per_page, "Number of results on a page"

    it "should only have 1 parameter" do |example|
      expect(example.metadata[:parameters].length).to eq(1)
    end

    context "another parameter" do
      parameter :page, "Current page"

      it 'should have 2 parameters' do |example|
        expect(example.metadata[:parameters].length).to eq(2)
      end
    end
  end

  describe "nested response_fields" do
    response_field :per_page, "Number of results on a page"

    context "another response field" do
      response_field :page, "Current page"

      it "should have 2 response fields" do |example|
        expect(example.metadata[:response_fields].length).to eq(2)
      end
    end
  end

  callback "Order creation notification callback" do
    it "should provide a destination" do
      expect(destination).to be_a(RspecApiDocumentation::TestServer)
    end

    it "should return the same destination every time" do
      expect(destination).to equal(destination)
    end

    describe "trigger_callback" do
      let(:callback_url) { "http://example.com/callback-url" }
      let(:callbacks_triggered) { [] }

      trigger_callback do
        callbacks_triggered << nil
      end

      it "should get called once when do_callback is called" do
        do_callback
        expect(callbacks_triggered.length).to eq(1)
      end
    end

    describe "do_callback" do
      trigger_callback do
        uri = URI.parse(callback_url)
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.request Net::HTTP::Post.new(uri.path)
        end
      end

      context "when callback_url is defined" do
        let(:callback_url) { "http://www.example.net/callback" }

        it "should mock requests to the callback url to be handled by the destination" do
          called = false
          allow(destination).to receive(:call) do
            called = true
            [200, {}, []]
          end
          do_callback
          expect(called).to be_truthy
        end
      end

      context "when callback_url is not defined" do
        it "should raise an exception" do
          expect { do_callback }.to raise_error("You must define callback_url")
        end
      end
    end

    describe "post vs get data" do
      parameter :id, "User id"
      parameter :page, "Page to list"
      parameter :message, "Message on the order"

      let(:message) { "Thank you" }
      let(:page) { 2 }
      let(:id) { 1 }

      get "/users/:id/orders" do
        example "Page should be in the query string" do
          expect(client).to receive(method) do |path, data, headers|
            expect(path).to match(/^\/users\/1\/orders\?/)
            expect(path.split("?")[1].split("&").sort).to eq("page=2&message=Thank+you".split("&").sort)
            expect(data).to be_nil
            expect(headers).to be_nil
          end
          do_request
        end
      end

      post "/users/:id/orders" do
        example "Page should be in the post body" do
          expect(client).to receive(method).with("/users/1/orders", {"page" => 2, "message" => "Thank you"}, nil)
          do_request
        end
      end
    end
  end

  context "#app" do
    it "should provide access to the configurations app" do
      expect(app).to eq(RspecApiDocumentation.configuration.app)
    end

    context "defining a new app, in an example" do
      let(:app) { "Sinatra" }

      it "should use the user defined app" do
        expect(app).to eq("Sinatra")
      end
    end
  end

  context "#explanation" do
    post "/orders" do
      route_summary "Route summary"
      route_description "Route description"

      example "Creating an order" do |example|
        explanation "By creating an order..."
        expect(example.metadata[:explanation]).to eq("By creating an order...")
        expect(example.metadata[:route_summary]).to eq("Route summary")
        expect(example.metadata[:route_description]).to eq("Route description")
      end

      context "Nested context" do
        example "Inner example" do |example|
          expect(example.metadata[:explanation]).to be_nil
          expect(example.metadata[:route_summary]).to eq("Route summary")
          expect(example.metadata[:route_description]).to eq("Route description")
        end
      end
    end
  end

  context "proper query_string serialization" do
    get "/orders" do
      context "with an array parameter" do
        parameter :id_eq, "List of IDs"

        let(:id_eq) { [1, 2] }

        example "parsed properly" do
          expect(client).to receive(:get) do |path, data, headers|
            expect(Rack::Utils.parse_nested_query(path.gsub('/orders?', ''))).to eq({"id_eq"=>['1', '2']})
          end
          do_request
        end
      end

      context "with a deep nested parameter, including Hashes and Arrays" do
        parameter :within_id, "Fancy search condition", :scope => :search

        let(:within_id) { {"first" => 1, "last" => 10, "exclude" => [3,5,7]} }

        example "parsed properly" do
          expect(client).to receive(:get) do |path, data, headers|
            expect(Rack::Utils.parse_nested_query(path.gsub('/orders?', ''))).to eq({
              "search" => { "within_id" => {"first" => '1', "last" => '10', "exclude" => ['3','5','7']}}
            })
          end
          do_request
        end
      end

      context "with reserved name parameter" do
        context "without custom method name" do
          parameter :status, "Filter order by status"

          example "does not work as expected" do
            expect { do_request }.to raise_error Rack::Test::Error, /No response yet/
          end
        end

        context "with custom method name" do
          parameter :status, "Filter order by status", method: :status_param

          context "when parameter value is not specified" do
            example "does not serialize param" do
              expect(client).to receive(method).with("/orders", anything, anything)
              do_request
            end
          end

          context "when parameter value is specified" do
            let(:status_param) { "pending" }

            example "serializes param" do
              expect(client).to receive(method).with("/orders?status=pending", anything, anything)
              do_request
            end
          end
        end
      end
    end
  end



  context "auto request" do
    post "/orders" do
      parameter :order_type, "Type of order"
      parameter :amount, "Amount of order", scope: :order
      parameter :name, "Name of order", scope: :order
      parameter :street, "order location country", scope: [:order,:location,:address]


      context "no extra params" do
        before do
          expect(client).to receive(:post).with("/orders", {}, nil)
        end

        example_request "Creating an order"

        example_request "should take a block" do
          params
        end
      end

      context "extra options for do_request" do
        before do
          expect(client).to receive(:post).with("/orders", {"order_type" => "big"}, nil)
        end

        example_request "should take an optional parameter hash", :order_type => "big"
      end

      context "extra options for do_request with scoped hash" do
        before do
          expect(client).to receive(:post).with("/orders", {"order_type" => "big", "order" => {"amount" => "19.99", "name" => "Friday Order"}}, nil)
        end

        let(:amount) { '19.99' }
        let(:name) { 'Monday Order' }

        example_request "should deep merge the optional parameter hash", {:order_type => 'big', :order => {:name => 'Friday Order'}}
      end

      context "extra options for do_request with nested scope" do
        before do
          expect(client).to receive(:post).with("/orders", {"order" => {"location" => {"address" => {"street" => "123 Main St"}}}}, nil)
        end

        let(:street) { '123 Main St' }

        example_request "should deep merge the optional parameter hash with nested scope"
      end
    end
  end

  context "request with only extra params" do
    post "/orders" do
      context "extra options for do_request" do
        before do
          expect(client).to receive(:post).with("/orders", {"order_type" => "big"}, nil)
        end

        example_request "should take an optional parameter hash", :order_type => "big"
      end
    end
  end

  context "last_response helpers" do
    put "/orders" do
      it "status" do
        allow(client).to receive(:last_response).and_return(double(:status => 200))
        expect(status).to eq(200)
      end

      it "response_body" do
        allow(client).to receive(:last_response).and_return(double(:body => "the body"))
        expect(response_body).to eq("the body")
      end
    end
  end

  context "headers" do
    put "/orders" do
      header "Accept", "application/json"

      it "should be sent with the request" do |example|
        expect(example.metadata[:headers]).to eq({ "Accept" => "application/json" })
      end

      context "nested headers" do
        header "Content-Type", "application/json"

        it "does not affect the outer context's assertions" do
          # pass
        end
      end
    end

    put "/orders" do
      context "setting header in example level" do
        before do
          header "Accept", "application/json"
          header "Content-Type", "application/json"
        end

        it "adds to headers" do
          expect(headers).to eq({ "Accept" => "application/json", "Content-Type" => "application/json" })
        end
      end
    end

    put "/orders" do
      header "Accept", :accept

      let(:accept) { "application/json" }

      it "should be sent with the request" do |example|
        expect(example.metadata[:headers]).to eq({ "Accept" => :accept })
      end

      it "should fill out into the headers" do
        expect(headers).to eq({ "Accept" => "application/json" })
      end

      context "nested headers" do
        header "Content-Type", "application/json"

        it "does not affect the outer context's assertions" do
          expect(headers).to eq({ "Accept" => "application/json", "Content-Type" => "application/json" })
        end
      end

      context "header was not let" do
        header "X-My-Header", :my_header

        it "should not be in the headers hash" do
          expect(headers).to eq({ "Accept" => "application/json" })
        end
      end
    end
  end

  context "authentications" do
    put "/orders" do
      authentication :apiKey, "Api Key", :name => "API_AUTH"
      authentication :basic, "Api Key"

      it "should be sent with the request" do |example|
        expect(example.metadata[:authentications]).to eq(
          {
            "API_AUTH" => {
              :in => :header,
              :type => :apiKey,
              :name => "API_AUTH"
            },
            "Authorization" => {
              :type => :basic
            }
          })
      end

      context "nested authentications" do
        authentication :apiKey, "Api Key", :name => "API_AUTH"

        it "does not affect the outer context's assertions" do
          # pass
        end
      end
    end

    put "/orders" do
      context "setting authentication in example level" do
        before do
          authentication :apiKey, "Api Key", :name => "API_AUTH"
        end

        it "adds to headers" do |example|
          expect(example.metadata[:authentications]).to eq({"API_AUTH" => {
            :in => :header,
            :type => :apiKey,
            :name => "API_AUTH"
          }})
        end
      end
    end

    put "/orders" do
      authentication :apiKey, :api_key, :name => "API_AUTH"

      let(:api_key) { "API_KEY_TOKEN" }

      it "should be sent with the request" do |example|
        expect(example.metadata[:authentications]).to eq({"API_AUTH" => {
          :in => :header,
          :type => :apiKey,
          :name => "API_AUTH"
        }})
      end

      it "should fill out into the headers" do
        expect(headers).to eq({ "API_AUTH" => "API_KEY_TOKEN" })
      end

      context "nested authentications" do
        authentication :apiKey, :api_key, :name => "API_AUTH"

        it "does not affect the outer context's assertions" do
          expect(headers).to eq({ "API_AUTH" => "API_KEY_TOKEN" })
        end
      end
    end
  end

  context "post body formatter" do
    after do
      RspecApiDocumentation.instance_variable_set(:@configuration, RspecApiDocumentation::Configuration.new)
    end

    get "/orders" do
      specify "formatting by json without parameters" do
        RspecApiDocumentation.configure do |config|
          config.request_body_formatter = :json
        end

        expect(client).to receive(method).with(path, nil, nil)

        do_request
      end
    end

    post "/orders" do
      parameter :page, "Page to view"

      let(:page) { 1 }

      specify "formatting by json" do
        RspecApiDocumentation.configure do |config|
          config.request_body_formatter = :json
        end

        expect(client).to receive(method).with(path, { :page => 1 }.to_json , nil)

        do_request
      end

      specify "formatting by json via legacy config" do
        RspecApiDocumentation.configure do |config|
          config.post_body_formatter = :json
        end

        expect(client).to receive(method).with(path, { :page => 1 }.to_json , nil)

        do_request
      end

      specify "formatting by xml" do
        RspecApiDocumentation.configure do |config|
          config.request_body_formatter = :xml
        end

        expect(client).to receive(method).with(path, { :page => 1 }.to_xml , nil)

        do_request
      end

      specify "formatting by proc" do
        RspecApiDocumentation.configure do |config|
          config.request_body_formatter = Proc.new do |params|
            { :from => "a proc" }.to_json
          end
        end

        expect(client).to receive(method).with(path, { :from => "a proc" }.to_json , nil)

        do_request
      end
    end
  end

  route "/orders{?application_id=:some_id}", "Orders Collection" do
    attribute :description, "Order description"

    it "saves the route URI" do |example|
      expect(example.metadata[:route_uri]).to eq "/orders"
    end

    it "saves the route optionals" do |example|
      expect(example.metadata[:route_optionals]).to eq "{?application_id=:some_id}"
    end

    it "saves the route name" do |example|
      expect(example.metadata[:route_name]).to eq "Orders Collection"
    end

    it "has 1 attribute" do |example|
      expect(example.metadata[:attributes]).to eq [{
        name: "description",
        description: "Order description"
      }]
    end

    get("Returns all orders") do
      it "uses the route URI" do
        expect(example.metadata[:route]).to eq "/orders"
      end

      it "bubbles down the parent group metadata" do
        expect(example.metadata[:method]).to eq :get
      end
    end
  end

  get "parameter with custom method only" do
    parameter :custom, "Custom name parameter", method: :custom_method, scope: :some

    context do
      let(:custom) { "Should not be taken" }
      let(:some_custom) { "Should not be taken" }

      it "not uses custom as value" do
        expect(params).to eq({})
      end
    end

    context do
      let(:custom_method) { "Should be taken" }

      it "uses custom_method as value" do
        expect(params).to eq("some" => {"custom" => "Should be taken"})
      end
    end
  end
end


resource "top level parameters" do
  parameter :page, "Current page"

  it 'should have 1 parameter' do |example|
    expect(example.metadata[:parameters].length).to eq(1)
  end
end

resource "top level response fields" do
  response_field :page, "Current page"

  it 'should have 1 response field' do |example|
    expect(example.metadata[:response_fields].length).to eq(1)
  end
end

resource "passing in document to resource", :document => :not_all do
  it "should have the correct tag" do |example|
    expect(example.metadata[:document]).to eq(:not_all)
  end
end

class Order; end
resource Order do
  it 'should have a string resource_name' do |example|
    expect(example.metadata[:resource_name]).to eq(Order.to_s)
  end
end
