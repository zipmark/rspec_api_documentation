require 'spec_helper'

describe RspecApiDocumentation::Index do
  let(:index) { RspecApiDocumentation::Index.new }

  subject { index }

  describe "#examples" do
    let(:examples) { [stub, stub] }

    before do
      index.examples.push(*examples)
    end

    it "should contain all added examples" do
      index.examples.should eq(examples)
    end
  end

  describe "#sections" do
    let(:example_1) { stub(:resource_name => "Order", :description => "Updating an order") }
    let(:example_2) { stub(:resource_name => "Order", :description => "Creating an order") }
    let(:example_3) { stub(:resource_name => "Cart", :description => "Creating an cart") }
    let(:examples) { [example_1, example_2, example_3] }

    before do
      index.examples.push(*examples)
    end

    subject { index.sections }

    it "should group examples by resource name" do
      subject.map { |resource| resource[:resource_name] }.should == ["Cart", "Order"]
    end

    it "should order examples by description" do
      subject.detect { |resource| resource[:resource_name] == "Order"}[:examples].should == [example_2, example_1]
    end
  end
end
