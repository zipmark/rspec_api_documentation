require 'spec_helper'
require 'rspec_api_documentation/dsl'

describe "Non-api documentation specs" do
  it "should not be polluted by the rspec api dsl" do
    example.example_group.should_not include(RspecApiDocumentation::DSL)
    example.example_group.should_not include(Rack::Test::Methods)
  end
end

resource "Order" do
  it "should include Rack::Test::Methods" do
    example.example_group.should include(Rack::Test::Methods)
  end

  describe "example metadata" do
    subject { example.metadata }

    its([:resource_name]) { should eq("Order") }
    its([:document]) { should be_true }
  end

  describe "example context" do
    it "should provide a client" do
      client.should be_a(RspecApiDocumentation::TestClient)
    end

    it "should return the same client every time" do
      client.should equal(client)
    end
  end

  [:post, :get, :put, :delete].each do |http_method|
    send(http_method, "/path") do
      specify { example.example_group.description.should eq("#{http_method.to_s.upcase} /path") }

      describe "example metadata" do
        subject { example.metadata }

        its([:method]) { should eq(http_method) }
        its([:path]) { should eq("/path") }
      end

      describe "example context" do
        subject { self }

        its(:method) { should eq(http_method) }
        its(:path) { should eq("/path") }

        describe "do_request" do
          it "should call the correct method on the client" do
            client.should_receive(http_method)
            do_request
          end
        end
      end
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

      it "should include the documentated parameters" do
        subject[:parameters].should eq(
          [
            { :name => "type", :description => "The type of drink you want.", :required => true },
            { :name => "size", :description => "The size of drink you want.", :required => true },
            { :name => "note", :description => "Any additional notes about your order." }
          ]
        )
      end
    end

    describe "example context" do
      subject { self }

      describe "params" do
        it "should equal the assigned parameter values" do
          params.should eq("type" => "coffee", "size" => "medium")
        end
      end
    end

    describe "do_request" do
      context "when raw_post is defined" do
        let(:raw_post) { { :bill => params }.to_json }

        it "should send the raw post body" do
          client.should_receive(method).with(path, raw_post)
          do_request
        end
      end

      context "when raw_post is not defined" do
        it "should send the params hash" do
          client.should_receive(method).with(path, params)
          do_request
        end
      end
    end
  end

  get "/orders/:id" do
    let(:order) { stub(:id => 1) }

    describe "path" do
      subject { self.path }

      context "when id has been defined" do
        let(:id) { order.id }

        it "should have the value of id subtituted for :id" do
          subject.should eq("/orders/1")
        end
      end

      context "when id has not been defined" do
        it "should be unchanged" do
          subject.should eq("/orders/:id")
        end
      end
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
  #

  describe "nested parameters" do
    parameter :per_page, "Number of results on a page"

    it "should only have 1 parameter" do
      example.metadata[:parameters].length.should == 1
    end

    context "another parameter" do
      parameter :page, "Current page"

      it 'should have 2 parameters' do
        example.metadata[:parameters].length.should == 2
      end
    end
  end
end
