require 'spec_helper'

RSpec::Matchers.define :group do |*expected|
  match do |actual|
    arr = actual.select { |resource| resource[:resource_name] == @group }
    arr.should have_exactly(1).item
    @examples = arr.first[:examples]
    @examples.should =~ expected
  end

  chain :in do |group|
    @group = group
  end

  failure_message_for_should do |actual|
    "expected #{@examples.map(&:description)} to be grouped in #{@group}"
  end
end

describe RspecApiDocumentation::IndexWriter do
  describe "#sections" do
    let(:example_1) { stub(:resource_name => "Order", :description => "Updating an order") }
    let(:example_2) { stub(:resource_name => "Order", :description => "Creating an order") }
    let(:example_3) { stub(:resource_name => "Cart", :description => "Creating an cart") }
    let(:examples) { [example_1, example_2, example_3] }

    context "with default value for keep_source_order" do
      let(:configuration) { RspecApiDocumentation::Configuration.new }
      subject { RspecApiDocumentation::IndexWriter.sections(examples, configuration) }

      it "should group examples by resource name" do
        subject.should group(example_1, example_2).in("Order")
        subject.should group(example_3).in("Cart")
      end

      it "should order resources by resource name" do
        subject.map { |resource| resource[:resource_name] }.should == ["Cart", "Order"]
      end

      it "should order examples by description" do
        subject.detect { |resource| resource[:resource_name] == "Order"}[:examples].should == [example_2, example_1]
      end
    end

    context "with keep_source_order set to true" do
      subject { RspecApiDocumentation::IndexWriter.sections(examples, stub(:keep_source_order => true)) }

      it "should order resources by source code declaration" do
        subject.map { |resource| resource[:resource_name] }.should == ["Order", "Cart"]
      end

      it "should order examples by source code declaration" do
        subject.detect { |resource| resource[:resource_name] == "Order"}[:examples].should == [example_1, example_2]
      end
    end
  end
end
