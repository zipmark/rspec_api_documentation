require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Order" do
  let(:order) { stub(:id => 1) }
  let(:id) { order.id }

  describe "example metadata" do
    subject { example.metadata }

    its([:resource_name]) { should eq("Order") }
  end

  describe "example context" do
    it "should provide a client" do
      client.should be_a(RspecApiDocumentation::TestClient)
    end

    it "should return the same client every time" do
      client.should equal(client)
    end
  end

  post "/orders" do
    parameter :type, "The type of drink you want."
    parameter :size, "The size of drink you want."
    parameter :note, "Any additional notes about your order."

    required_parameters :type, :size

    let(:type) { "coffee" }
    let(:size) { "medium" }

    describe "example metadata" do
      subject { example.metadata }

      its([:method]) { should eq(:post) }
      its([:path]) { should eq("/orders") }

      it "should include the documentated parameters" do
        subject[:parameters].should eq(
          :type => { :description => "The type of drink you want.", :required => true },
          :size => { :description => "The size of drink you want.", :required => true },
          :note => { :description => "Any additional notes about your order." }
        )
      end
    end

    describe "example context" do
      subject { self }

      its(:method) { should eq(:post) }
      its(:path) { should eq("/orders") }

      describe "params" do
        it "should equal the assigned parameter values" do
          params.should eq(:type => "coffee", :size => "medium")
        end
      end

      describe "do_request" do
        it "should call the correct method on the client" do
          client.should_receive(:post)
          do_request
        end
      end
    end
  end

  get "/orders/:id" do
    describe "example metadata" do
      subject { example.metadata }

      its([:method]) { should eq(:get) }
      its([:path]) { should eq("/orders/:id") }
    end

    describe "example context" do
      subject { self }

      its(:method) { should eq(:get) }
      its(:path) { should eq("/orders/:id") }
    end
  end

  put "/orders/:id" do
    describe "example metadata" do
      subject { example.metadata }

      its([:method]) { should eq(:put) }
      its([:path]) { should eq("/orders/:id") }
    end

    describe "example context" do
      subject { self }

      its(:method) { should eq(:put) }
      its(:path) { should eq("/orders/:id") }
    end
  end

  delete "/orders/:id" do
    describe "example metadata" do
      subject { example.metadata }

      its([:method]) { should eq(:delete) }
      its([:path]) { should eq("/orders/:id") }
    end

    describe "example context" do
      subject { self }

      its(:method) { should eq(:delete) }
      its(:path) { should eq("/orders/:id") }
    end
  end

  #  parameter :type, "The type of drink you want."
  #  parameter :size, "The size of drink you want."
  #  parameter :note, "Any additional notes about your order."

  #  required_parameters :type, :size

  #  raw_post { { :bill => params }.to_json }

  #  example_request "Ordering a cup of coffee" do
  #    param(:type) { "coffee" }
  #    param(:size) { "cup" }

  #    should_respond_with_status eq(200)
  #    should_respond_with_body eq("Order created")
  #  end

  #  example_request "An invalid order" do
  #    param(:type) { "caramel macchiato" }
  #    param(:note) { "whipped cream" }

  #    should_respond_with_status eq(400)
  #    should_respond_with_body json_eql({:errors => {:size => ["can't be blank"]}}.to_json)
  #  end
  #end
end
