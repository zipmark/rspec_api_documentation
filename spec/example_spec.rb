require 'spec_helper'

describe RspecApiDocumentation::Example do
  let(:description) { "foo" }
  let(:metadata) {{ :resource_name => "foo", :document => true }}
  let(:rspec_example_group) { RSpec::Core::ExampleGroup.describe("foobar") }
  let(:rspec_example) { rspec_example_group.example(description, metadata) {} }
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:example) { RspecApiDocumentation::Example.new(rspec_example, configuration) }

  subject { example }

  it { should be_a(Mustache) }

  its(:example) { should equal(rspec_example) }
  its(:configuration) { should equal(configuration) }
  its(:template_path) { should eq(configuration.template_path) }
  its(:template_extension) { should eq(configuration.format.to_s) }

  describe "method delegation" do
    context "when the example's metadata has a key for the given method selector" do
      let(:metadata) {{ :foo => nil }}

      it "should return the metadata value for the given method selector as a key" do
        example.should respond_to(:foo)
        example.foo.should eq(nil)
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

  describe "#dirname" do
    let(:metadata) {{ :resource_name => "something\n  More \tcomplicAtEd" }}

    it "should be a sanitized, filename-safe representation of the resource name" do
      example.dirname.should eq("something_more_complicated")
    end
  end

  describe "#filename" do
    let(:description) { "Some$T:hing\n\tComPlicaTed" }
    it "should return a sanitized, filename-safe representation of the description" do
      example.filename.should eq("something_complicated.html")
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

  describe "has_parameters?" do
    subject { example.has_parameters? }

    context "when parameters are defined" do
      before { example.stub!(:parameters).and_return([stub]) }

      it { should be_true }
    end

    context "when parameters are empty" do
      before { example.stub!(:parameters).and_return([]) }

      it { should be_false }
    end

    context "when parameters are not defined" do
      it { should be_false }
    end
  end

  describe "json" do
    it "should produce json" do
      # TODO this is probably a smell
      example.metadata.merge!(:request_headers => [], :route => [], :method => [],
                              :resource_name => [], :request_body => [], :response_headers => [],
                              :response_status => [], :response_body => [])

      example.json.should_not be_nil
    end
  end
end
