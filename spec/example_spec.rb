require 'spec_helper'

describe RspecApiDocumentation::Example do
  let(:description) { "foo" }
  let(:metadata) {{ :resource_name => "foo", :document => true }}
  let(:rspec_example_group) { RSpec::Core::ExampleGroup.describe("foobar") }
  let(:rspec_example) { rspec_example_group.example(description, metadata) {} }
  let(:wrapped_example_group) { stub }
  let(:example) { RspecApiDocumentation::Example.new(rspec_example) }

  subject { example }

  before do
    RspecApiDocumentation::ExampleGroup.stub!(:new).with(rspec_example_group).and_return(wrapped_example_group)
  end

  it { should be_a(Mustache) }

  its(:example) { should equal(rspec_example) }

  describe "method delegation" do
    context "when the example's metadata has a key for the given method selector" do
      let(:metadata) {{ :foo => :bar }}

      it "should return the metadata value for the given method selector as a key" do
        example.should respond_to(:foo)
        example.foo.should eq(:bar)
      end
    end

    context "when the example's metadata has no key for the given method selector" do
      before { metadata.delete(:foo) }

      it "should delegate the method to the example" do
        rspec_example.should_receive(:foo).with(:bar, :baz)
        example.should respond_to(:foo)
        example.foo(:bar, :baz)
      end
    end
  end

  describe "#method" do
    let(:metadata) {{ :method => "GET" }}

    it "should return what is in the metadata" do
      example.method.should == "GET"
    end
  end

  describe "#example_group" do
    it "should return the wrapped example group" do
      example.example_group.should equal(wrapped_example_group)
    end
  end

  describe "#dirname" do
    it "should return the wrapped example group's dirname" do
      dirname = stub
      wrapped_example_group.stub!(:dirname).and_return(dirname)
      example.dirname.should equal(dirname)
    end
  end

  describe "#filename" do
    let(:description) { "Some$T:hing\n\tComPlicaTed" }
    it "should return a sanitized, filename-safe representation of the description" do
      example.filename.should eq("something_complicated")
    end
  end

  describe "#should_document?" do
    subject { example.should_document? }

    context "when the example's metadata defines a resource name and its document setting is truthy" do
      let(:metadata) {{ :resource_name => "foo", :document => true }}

      it { should be_true }
    end

    context "when the example's metadata does not define a resource name" do
      let(:metadata) {{ :document => true }}

      it { should be_false }
    end

    context "when the example's metadata document setting is falsy" do
      let(:metadata) {{ :resource_name => "foo", :document => false }}

      it { should be_false }
    end

    context "when the example is pending" do
      let(:rspec_example) { rspec_example_group.pending(description, metadata) {} }

      it { should be_false }
    end
  end

  describe "#public?" do
    subject { example.public? }

    context "when the example's metadata public setting is truthy" do
      let(:metadata) {{ :public => true }}

      it { should be_true }
    end

    context "when the example's metadata public setting is falsy" do
      let(:metadata) {{ :public => false }}

      it { should be_false }
    end
  end
end
