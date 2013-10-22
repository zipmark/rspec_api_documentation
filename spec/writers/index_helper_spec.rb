require 'spec_helper'

describe RspecApiDocumentation::Writers::IndexHelper do
  describe "#sections" do
    let(:example_1) { double(:resource_name => "Order", :description => "Updating an order") }
    let(:example_2) { double(:resource_name => "Order", :description => "Creating an order") }
    let(:example_3) { double(:resource_name => "Cart", :description => "Creating an cart") }
    let(:examples) { [example_1, example_2, example_3] }

    context "with default value for keep_source_order" do
      let(:configuration) { RspecApiDocumentation::Configuration.new }
      subject { RspecApiDocumentation::Writers::IndexHelper.sections(examples, configuration) }

      it "should order resources by resource name" do
        subject.map { |resource| resource[:resource_name] }.should == ["Cart", "Order"]
      end

      it "should order examples by description" do
        subject.detect { |resource| resource[:resource_name] == "Order"}[:examples].should == [example_2, example_1]
      end
    end

    context "with keep_source_order set to true" do
      subject { RspecApiDocumentation::Writers::IndexHelper.sections(examples, double(:keep_source_order => true)) }

      it "should order resources by source code declaration" do
        subject.map { |resource| resource[:resource_name] }.should == ["Order", "Cart"]
      end

      it "should order examples by source code declaration" do
        subject.detect { |resource| resource[:resource_name] == "Order"}[:examples].should == [example_1, example_2]
      end
    end
  end
end
