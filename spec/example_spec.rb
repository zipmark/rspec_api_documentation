require 'spec_helper'

describe RspecApiDocumentation::Example do
  let(:description) { "foo" }
  let(:metadata) {{ :resource_name => "foo", :document => true }}
  let(:rspec_example_group) { RSpec::Core::ExampleGroup.describe("foobar") }
  let(:rspec_example) { rspec_example_group.example(description, metadata) {} }
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:example) { RspecApiDocumentation::Example.new(rspec_example, configuration) }

  subject { example }

  its(:example) { should equal(rspec_example) }
  its(:configuration) { should equal(configuration) }

  describe "method delegation" do
    context "when the example's metadata has a key for the given method selector" do
      let(:metadata) {{ :foo => nil }}

      it "should return the metadata value for the given method selector as a key" do
        expect(example).to respond_to(:foo)
        expect(example.foo).to eq(nil)
      end
    end

    context "when the example's metadata has no key for the given method selector" do
      before { metadata.delete(:foo) }

      it "should delegate the method to the example" do
        expect(rspec_example).to receive(:foo).with(:bar, :baz)
        expect(example).to respond_to(:foo)
        example.foo(:bar, :baz)
      end
    end
  end

  describe "#http_method" do
    let(:metadata) {{ :method => "GET" }}

    it "should return what is in the metadata" do
      expect(example.http_method).to eq("GET")
    end
  end

  describe "#should_document?" do
    subject { example.should_document? }

    context "when the example's metadata defines a resource name and its document setting is truthy" do
      let(:metadata) {{ :resource_name => "foo", :document => true }}

      it { should be_truthy }
    end

    context "when the example's metadata does not define a resource name" do
      let(:metadata) {{ :document => true }}

      it { should be_falsey }
    end

    context "when the example's metadata document setting is falsy" do
      let(:metadata) {{ :resource_name => "foo", :document => false }}

      it { should be_falsey }
    end

    context "when the example is pending" do
      let(:rspec_example) { rspec_example_group.pending(description, metadata) {} }

      it { should be_falsey }
    end

    context "configuration sets a filter" do
      before do
        configuration.filter = :public
        configuration.exclusion_filter = :excluded
      end

      context "when the example does match the filter" do
        let(:metadata) { { :resource_name => "foo", :document => :public } }

        it { should be_truthy }
      end

      context "when the example does not match the filter" do
        let(:metadata) { { :resource_name => "foo", :document => :private } }

        it { should be_falsey }
      end

      context "when the example is excluded" do
        let(:metadata) { { :resource_name => "foo", :document => [:public, :excluded] } }

        it { should be_falsey }
      end
    end

    context "configuration only sets an exclusion filter" do
      before do
        configuration.exclusion_filter = :excluded
      end

      context "when example doesn't match exclusion" do
        let(:metadata) { { :resource_name => "foo", :document => :public } }

        it { should be_truthy }
      end

      context "when example matches exclusion" do
        let(:metadata) { { :resource_name => "foo", :document => [:public, :excluded] } }

        it { should be_falsey }
      end
    end
  end

  describe "#public?" do
    subject { example.public? }

    context "when the example's metadata public setting is truthy" do
      let(:metadata) {{ :public => true }}

      it { should be_truthy }
    end

    context "when the example's metadata public setting is falsy" do
      let(:metadata) {{ :public => false }}

      it { should be_falsey }
    end
  end

  describe "has_parameters?" do
    subject { example.has_parameters? }

    context "when parameters are defined" do
      before { allow(example).to receive(:parameters).and_return([double]) }

      it { should be_truthy }
    end

    context "when parameters are empty" do
      before { allow(example).to receive(:parameters).and_return([]) }

      it { should be_falsey }
    end

    context "when parameters are not defined" do
      it { should be_falsey }
    end
  end

  describe "has_attributes?" do
    subject { example.has_attributes? }

    context "when attributes are defined" do
      before { allow(example).to receive(:attributes).and_return([double]) }

      it { should eq true }
    end

    context "when attributes are empty" do
      before { allow(example).to receive(:attributes).and_return([]) }

      it { should eq false }
    end

    context "when attributes are not defined" do
      it { should be_falsey }
    end
  end

  describe "has_response_fields?" do
    subject { example.has_response_fields? }

    context "when response fields are defined" do
      before { allow(example).to receive(:response_fields).and_return([double]) }

      it { should be_truthy }
    end

    context "when response fields are empty" do
      before { allow(example).to receive(:response_fields).and_return([]) }

      it { should be_falsey }
    end

    context "when response fields are not defined" do
      it { should be_falsey }
    end
  end

  describe "#resource_explanation" do
    it "should return the metadata resource_explanation" do
      example.metadata[:resource_explanation] = "Here is a resource explanation"
      expect(example.resource_explanation).to eq("Here is a resource explanation")
    end

    it "should return an empty string when not set" do
      expect(example.resource_explanation).to eq(nil)
    end
  end

  describe "#explanation" do
    it "should return the metadata explanation" do
      example.metadata[:explanation] = "Here is an explanation"
      expect(example.explanation).to eq("Here is an explanation")
    end

    it "should return an empty string when not set" do
      expect(example.explanation).to eq(nil)
    end
  end

  describe "request headers can be filtered" do
    before do
      configuration.request_headers_to_include = %w[Included]
      metadata[:requests] = [
          {
              :request_headers => {
                  "Included" => "data",
                  "Filtered" => "not seen"
              },
              :request_method => "GET"
          },
          {
              :request_headers => {
                  "included" => "data",
                  "Other" => "not seen"
              },
              :request_method => "GET"
          }
      ]
    end

    it "should filter out anything not explicitly mentioned" do
      expect(subject.requests).to eq([
          {
              :request_headers => {
                  "Included" => "data",
              },
              :request_method => "GET"
          },
          {
              :request_headers => {
                  "included" => "data",
              },
              :request_method => "GET"
          }
      ])
    end
  end

  describe "response headers can be filtered" do
    before do
      configuration.response_headers_to_include = %w[Included]
      metadata[:requests] = [
          {
              :response_headers => {
                  "Included" => "data",
                  "Filtered" => "not seen"
              },
              :request_method => "GET"
          },
          {
              :response_headers => {
                  "included" => "data",
                  "Other" => "not seen"
              },
              :request_method => "GET"
          }
      ]
    end

    it "should filter out anything not explicitly mentioned" do
      expect(subject.requests).to eq([
          {
              :response_headers => {
                  "Included" => "data",
              },
              :request_method => "GET"
          },
          {
              :response_headers => {
                  "included" => "data",
              },
              :request_method => "GET"
          }
      ])
    end
  end
end
