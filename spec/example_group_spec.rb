require 'spec_helper'

describe RspecApiDocumentation::ExampleGroup do
  let(:metadata) {{ :resource_name => "foobar", :document => true }}
  let(:rspec_example_group) { RSpec::Core::ExampleGroup.describe("test example group", metadata) }
  let(:foo_example) { rspec_example_group.example("foo") }
  let(:bar_example) { rspec_example_group.example("bar") }
  let(:wrapped_foo_example) { stub(:should_document? => true, :public? => true) }
  let(:wrapped_bar_example) { stub(:should_document? => true, :public? => true) }
  let(:example_group) { RspecApiDocumentation::ExampleGroup.new(rspec_example_group) }

  subject { example_group }

  before do
    RspecApiDocumentation::Example.stub!(:new).with(foo_example).and_return(wrapped_foo_example)
    RspecApiDocumentation::Example.stub!(:new).with(bar_example).and_return(wrapped_bar_example)
  end

  it { should be_a(Mustache) }

  its(:example_group) { should equal(rspec_example_group) }

  it "should delegate to the rspec example group for any method it doesn't understand" do
    rspec_example_group.should_receive(:foo).with(:bar, :baz)
    example_group.foo(:bar, :baz)
  end

  describe "#dirname" do
    let(:metadata) {{ :resource_name => "something\n  More \tcomplicAtEd" }}

    it "should be a sanitized, filename-safe representation of the resource name" do
      example_group.dirname.should eq("something_more_complicated")
    end
  end

  describe "#examples" do
    it "should return each example, wrapped" do
      example_group.examples.should eq([wrapped_foo_example, wrapped_bar_example])
    end
  end

  describe "#documented_examples" do
    before do
      wrapped_bar_example.stub!(:should_document?).and_return(false)
    end

    it "should return only those examples which should be documented" do
      example_group.documented_examples.should eq([wrapped_foo_example])
    end
  end

  describe "#public_examples" do
    before do
      wrapped_bar_example.stub!(:public? => false)
    end

    it "should return only those examples which should be publicly documented" do
      example_group.public_examples.should eq([wrapped_foo_example])
    end
  end
end
