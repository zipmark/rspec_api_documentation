require 'acceptance_helper'

resource "Orders" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  explanation "Orders are top-level business objects"

  let(:order) { Order.create(:name => "Old Name", :paid => true, :email => "email@example.com") }

  get "/orders" do
    authentication :apiKey, "API_TOKEN", :name => "AUTH_TOKEN"
    parameter :page, "Current page of orders", with_example: true

    let(:page) { 1 }

    before do
      2.times do |i|
        Order.create(:name => "Order #{i}", :email => "email#{i}@example.com", :paid => true)
      end
    end

    example_request "Getting a list of orders" do
      expect(response_body).to eq(Order.all.to_json)
      expect(status).to eq(200)
    end
  end

  head "/orders" do
    authentication :apiKey, "API_TOKEN", :name => "AUTH_TOKEN"

    example_request "Getting the headers" do
      expect(response_headers["Cache-Control"]).to eq("max-age=0, private, must-revalidate")
    end
  end

  post "/orders" do
    with_options :scope => :order, :with_example => true do
      parameter :name, "Name of order", :required => true
      parameter :paid, "If the order has been paid for", :required => true
      parameter :email, "Email of user that placed the order"
      parameter :data, "Array of string", :type => :array, :items => {:type => :string}
    end

    with_options :scope => :order do
      response_field :name, "Name of order", :type => :string
      response_field :paid, "If the order has been paid for", :type => :boolean
      response_field :email, "Email of user that placed the order", :type => :string
    end

    let(:name) { "Order 1" }
    let(:paid) { true }
    let(:email) { "email@example.com" }
    let(:data) { ["good", "bad"] }

    let(:raw_post) { params.to_json }

    example_request "Creating an order" do
      explanation "First, create an order, then make a later request to get it back"

      order = JSON.parse(response_body)
      expect(order.except("id", "created_at", "updated_at")).to eq({
        "name" => name,
        "paid" => paid,
        "email" => email,
      })
      expect(status).to eq(201)

      client.get(URI.parse(response_headers["location"]).path, {}, headers)
      expect(status).to eq(200)
    end
  end

  get "/orders/:id" do
    context "when id is valid" do
      let(:id) { order.id }

      example_request "Getting a specific order" do
        expect(response_body).to eq(order.to_json)
        expect(status).to eq(200)
      end
    end

    context "when id is invalid" do
      let(:id) { "a" }

      example_request "Getting an error" do
        expect(response_body).to eq ""
        expect(status).to eq 404
      end
    end
  end

  put "/orders/:id" do
    with_options :scope => :order, with_example: true do
      parameter :name, "Name of order"
      parameter :paid, "If the order has been paid for"
      parameter :email, "Email of user that placed the order"
    end

    let(:id) { order.id }
    let(:name) { "Updated Name" }

    let(:raw_post) { params.to_json }

    example_request "Updating an order" do
      expect(status).to eq(204)
    end
  end

  delete "/orders/:id" do
    let(:id) { order.id }

    example_request "Deleting an order" do
      expect(status).to eq(204)
    end
  end
end
