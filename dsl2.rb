resource "Orders" do
  let(:client) { RspecApiDocumentation::RackTestClient.new(self, :headers => { "Accept" => format }) }

  get "/orders", "Listing orders" do
    request "XML" do
      let(:format) { "xml" }

      before do
        req = do_request
        metadata[:req] = req #! superclass.metadata
      end

      context "Bad" do
        it "should have the correct header" do
          response_headers["Content-Type"].should == "application/xml"
        end

        it "should have the correct status" do
          status.should == 200
        end
      end

      it "should have the correct body" do
        response_body.should match(/my expectation/)
      end
    end

    request "JSON" do
      let(:format) { "json" }

      it "should have the correct header" do
        response_headers["Content-Type"].should == "application/json"
      end

      it "should have the correct status" do
        status.should == 200
      end

      it "should have the correct body" do
        response_body.should match(/my expectation/)
      end
    end
  end

  post "/orders", "Creating an order" do
    parameter :name, "name of order"
    parameter :size, "Size of order"

    required_parameters :name

    let(:name) { "Name of order" }

    request "XML" do
      let(:format) { "xml" }

      its(:status) { should == 201 }
    end

    request "JSON" do
      let(:format) { "json" }

      its(:status) { should == 201 }

      it "should have the correct information" do
        response_body.should be_json_eql({:name => "Name of order"}.to_json)
      end
    end
  end

  get "/orders/:id", "Viewing an order" do
    let(:id) { order.id }

    request "Someone else's order" do
      let(:format) { "json" }
      let(:id) { create(:order).id }

      its(:status) { should == 403 }
    end
  end

  delete "/orders/:id", "Deleting an order" do
    let(:id) { order.id }

    its(:status) { should == 200 }

    request "Someone else's order" do
      let(:id) { create(:order).id }

      its(:status) { should == 403 }
    end
  end
end
