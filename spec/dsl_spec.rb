require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Order" do
  let(:order) { stub(:id => 1) }
  let(:id) { order.id }

  it "should set the resource name metadata" do
    example.metadata[:resource_name].should eq("Order")
  end

  it "it should provide a client" do
    client.should be_a(RspecApiDocumentation::TestClient)
  end

  it "should return the same client every time" do
    client.should equal(client)
  end

  post "/orders" do
    parameter :type, "The type of drink you want."
    parameter :size, "The size of drink you want."
    parameter :note, "Any additional notes about your order."

    required_parameters :type, :size

    let(:type) { "coffee" }
    let(:size) { "medium" }

    describe "metadata" do
      it "should include method information" do
        example.metadata[:method].should eq(:post)
      end

      it "should include path information" do
        example.metadata[:path].should eq("/orders")
      end

      it "should include parameter information" do
        example.metadata[:parameters].should eq(
          :type => { :description => "The type of drink you want.", :required => true },
          :size => { :description => "The size of drink you want.", :required => true },
          :note => { :description => "Any additional notes about your order." }
        )
      end
    end

    describe "#method" do
      it "should expose the method" do
        method.should eq(:post)
      end
    end

    describe "#path" do
      it "should expose the path" do
        path.should eq("/orders")
      end
    end

    describe "#params" do
      it "should expose set parameter values" do
        params.should eq(:type => "coffee", :size => "medium")
      end
    end

    describe "#do_request" do
      it "should call the correct method on the client" do
        client.should_receive(:post)
        do_request
      end
    end
  end

  get "/orders/:id" do
    it "should set the method metadata" do
      example.metadata[:method].should eq(:get)
    end

    it "should set the path metadata" do
      example.metadata[:path].should eq("/orders/:id")
    end
  end

  put "/orders/:id" do
    it "should set the method metadata" do
      example.metadata[:method].should eq(:put)
    end

    it "should set the path metadata" do
      example.metadata[:path].should eq("/orders/:id")
    end
  end

  delete "/orders/:id" do
    it "should set the method metadata" do
      example.metadata[:method].should eq(:delete)
    end

    it "should set the path metadata" do
      example.metadata[:path].should eq("/orders/:id")
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
