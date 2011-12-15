require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Orders" do
  parameter :format, "Format of response"

  required_parameters :format

  let(:format) { :json }

  let(:order) { Order.create(:name => "Old Name", :paid => true, :email => "email@example.com") }

  get "/orders.:format" do
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

  post "/orders.:format" do
    parameter :name, "Name of order"
    parameter :paid, "If the order has been paid for"
    parameter :email, "Email of user that placed the order"

    let(:name) { "Order 1" }
    let(:paid) { true }
    let(:email) { "email@example.com" }

    scope_parameters :order, [:name, :paid, :email]

    example "Creating an order" do
      do_request

      last_response.status.should == 201
      json = JSON.parse(last_response.body)
      json.should == {
        "name"=> name,
        "paid"=> paid,
        "email" => email,
      }
    end
  end

  get "/orders/:id.:format" do
    parameter :id, "ID of order"

    let(:id) { order.id }

    example "Getting a specific order" do
      do_request

      last_response.body.should == order.to_json
      last_response.should be_ok
    end
  end

  put "/orders/:id.:format" do
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

  delete "/orders/:id.:format" do
    parameter :id, "ID of order"

    let(:id) { order.id }

    example "Deleting an order" do
      do_request

      last_response.should be_ok
    end
  end
end
