require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Orders" do
  let(:order) { Order.create(:name => "Old Name", :paid => true, :email => "email@example.com") }

  let(:client) { RspecApiDocumentation::TestClient.new(self, :headers => { "HTTP_ACCEPT" => "application/json" }) }

  get "/orders" do
    parameter :page, "Current page of orders"

    let(:page) { 1 }

    before do
      2.times do |i|
        Order.create(:name => "Order #{i}", :email => "email#{i}@example.com", :paid => true)
      end
    end

    example "Getting a list of orders" do
      do_request

      last_response.body.should == Order.all.to_json
      last_response.should be_ok
    end
  end

  post "/orders" do
    parameter :name, "Name of order"
    parameter :paid, "If the order has been paid for"
    parameter :email, "Email of user that placed the order"

    required_parameters :name, :paid

    let(:name) { "Order 1" }
    let(:paid) { true }
    let(:email) { "email@example.com" }

    scope_parameters :order, [:name, :paid, :email]

    example "Creating an order" do
      do_request

      last_response.status.should == 201
      response_body.should be_json_eql({
        "name" => name,
        "paid" => paid,
        "email" => email,
      }.to_json)

      order = JSON.parse(response_body)

      client.get(URI.parse(last_response.headers["location"]).path)
      status.should == 200
    end
  end

  get "/orders/:id" do
    parameter :id, "ID of order"

    let(:id) { order.id }

    example "Getting a specific order" do
      do_request

      last_response.body.should == order.to_json
      last_response.should be_ok
    end
  end

  put "/orders/:id" do
    parameter :id, "ID of order"
    parameter :name, "Name of order"
    parameter :paid, "If the order has been paid for"
    parameter :email, "Email of user that placed the order"

    let(:id) { order.id }

    let(:name) { "Updated Name" }

    scope_parameters :order, [:name]

    example "Updating an order" do
      do_request

      last_response.should be_ok
    end
  end

  delete "/orders/:id" do
    parameter :id, "ID of order"

    let(:id) { order.id }

    example "Deleting an order" do
      do_request

      last_response.should be_ok
    end
  end
end
