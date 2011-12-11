require 'spec_helper'
require 'rspec_api_documentation/dsl'
require 'net/http'

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

      it "should allow extra parameters to be passed in" do
        client.should_receive(method).with(path, params.merge("extra" => true))
        do_request(:extra => true)
      end

      it "should overwrite parameters" do
        client.should_receive(method).with(path, params.merge("size" => "large"))
        do_request(:size => "large")
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

  callback "Order creation notification callback" do
    it "should provide a destination" do
      destination.should be_a(RspecApiDocumentation::TestServer)
    end

    it "should return the same destination every time" do
      destination.should equal(destination)
    end

    describe "trigger_callback" do
      let(:callback_url) { stub }
      let(:callbacks_triggered) { [] }

      trigger_callback do
        callbacks_triggered << nil
      end

      it "should get called once when do_callback is called" do
        do_callback
        callbacks_triggered.length.should eq(1)
      end
    end

    describe "do_callback" do
      trigger_callback do
        uri = URI.parse(callback_url)
        Net::HTTP.start(uri.host, uri.port) do |http|
          # debugger
          http.request Net::HTTP::Post.new(uri.path)
        end
      end

      context "when callback_url is defined" do
        let(:callback_url) { "http://www.example.net/callback" }

        it "should mock requests to the callback url to be handled by the destination" do
          called = false
          destination.stub!(:call).and_return do
            called = true
            [200, {}, []]
          end
          do_callback
          called.should be_true
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
          client.should_receive(method).with("/users/1/orders?page=2&message=Thank+you", nil)
          do_request
        end
      end

      post "/users/:id/orders" do
        example "Page should be in the post body" do
          client.should_receive(method).with("/users/1/orders", {"page" => 2, "message" => "Thank you"})
          do_request
        end
      end
    end
  end
end

resource "top level parameters" do
  parameter :page, "Current page"

  it 'should have 1 parameter' do
    example.metadata[:parameters].length.should == 1
  end
end
