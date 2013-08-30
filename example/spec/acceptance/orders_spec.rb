require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Orders" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:order) { Order.create(:name => "Old Name", :paid => true, :email => "email@example.com") }

  get "/orders" do
    parameter :page, "Current page of orders"

    let(:page) { 1 }

    before do
      2.times do |i|
        Order.create(:name => "Order #{i}", :email => "email#{i}@example.com", :paid => true)
      end
    end

    example_request "Getting a list of orders" do
      response_body.should == Order.all.to_json
      status.should == 200
    end
  end

  head "/orders" do
    example_request "Getting the headers" do
      response_headers["Content-Type"].should == "application/json; charset=utf-8"
    end
  end

  post "/orders" do
    parameter :name, "Name of order", :required => true, :scope => :order
    parameter :paid, "If the order has been paid for", :required => true, :scope => :order
    parameter :email, "Email of user that placed the order", :scope => :order

    let(:name) { "Order 1" }
    let(:paid) { true }
    let(:email) { "email@example.com" }

    let(:raw_post) { params.to_json }

    example_request "Creating an order" do
      explanation "First, create an order, then make a later request to get it back"
      response_body.should be_json_eql({
        "name" => name,
        "paid" => paid,
        "email" => email,
      }.to_json)
      status.should == 201

      order = JSON.parse(response_body)

      client.get(URI.parse(response_headers["location"]).path, {}, headers)
      status.should == 200
    end
  end

  get "/orders/:id" do
    let(:id) { order.id }

    example_request "Getting a specific order" do
      response_body.should == order.to_json
      status.should == 200
    end
  end

  put "/orders/:id" do
    parameter :name, "Name of order", :scope => :order
    parameter :paid, "If the order has been paid for", :scope => :order
    parameter :email, "Email of user that placed the order", :scope => :order

    let(:id) { order.id }
    let(:name) { "Updated Name" }

    let(:raw_post) { params.to_json }

    example_request "Updating an order" do
      status.should == 200
    end
  end

  delete "/orders/:id" do
    let(:id) { order.id }

    example_request "Deleting an order" do
      status.should == 200
    end
  end
end
