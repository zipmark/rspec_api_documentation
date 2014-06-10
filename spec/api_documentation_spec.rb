require 'spec_helper'

describe RspecApiDocumentation::ApiDocumentation do
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:documentation) { RspecApiDocumentation::ApiDocumentation.new(configuration) }

  subject { documentation }

  its(:configuration) { should equal(configuration) }
  its(:index) { should be_a(RspecApiDocumentation::Index) }

  describe "#clear_docs" do

    it "should rebuild the docs directory" do
      test_file = configuration.docs_dir.join("test")
      FileUtils.mkdir_p configuration.docs_dir
      FileUtils.touch test_file
      allow(FileUtils).to receive(:cp_r)
      subject.clear_docs

      expect(File.directory?(configuration.docs_dir)).to be_truthy
      expect(File.exists?(test_file)).to be_falsey
    end
  end

  describe "#document_example" do
    let(:metadata) {{ :should_document => true }}
    let(:group) { RSpec::Core::ExampleGroup.describe("test group") }
    let(:example) { group.example("test example", metadata) }
    let!(:wrapped_example) { RspecApiDocumentation::Example.new(example, configuration) }

    before do
      allow(RspecApiDocumentation::Example).to receive(:new).and_return(wrapped_example)
    end

    it "should create a new wrapped example" do
      expect(RspecApiDocumentation::Example).to receive(:new).with(example, configuration).and_return(wrapped_example)
      documentation.document_example(example)
    end

    context "when the given example should be documented" do
      before { allow(wrapped_example).to receive(:should_document?).and_return(true) }

      it "should add the wrapped example to the index" do
        documentation.document_example(example)
        expect(documentation.index.examples).to eq([wrapped_example])
      end
    end

    context "when the given example should not be documented" do
      before { allow(wrapped_example).to receive(:should_document?).and_return(false) }

      it "should not add the wrapped example to the index" do
        documentation.document_example(example)
        expect(documentation.index.examples).to be_empty
      end
    end
  end

  describe "#writers" do
    class RspecApiDocumentation::Writers::HtmlWriter; end
    class RspecApiDocumentation::Writers::JsonWriter; end
    class RspecApiDocumentation::Writers::TextileWriter; end

    context "multiple" do
      before do
        configuration.format = [:html, :json, :textile]
      end

      it "should return the classes from format" do
        expect(subject.writers).to eq([RspecApiDocumentation::Writers::HtmlWriter,
                                       RspecApiDocumentation::Writers::JsonWriter,
                                       RspecApiDocumentation::Writers::TextileWriter])
      end
    end

    context "single" do
      before do
        configuration.format = :html
      end

      it "should return the classes from format" do
        expect(subject.writers).to eq([RspecApiDocumentation::Writers::HtmlWriter])
      end
    end
  end

  describe "#write" do
    let(:html_writer)    { double(:html_writer) }
    let(:json_writer)    { double(:json_writer) }
    let(:textile_writer) { double(:textile_writer) }

    before do
      allow(subject).to receive(:writers).and_return([html_writer, json_writer, textile_writer])
    end

    it "should write the docs in each format" do
      expect(html_writer).to receive(:write).with(subject.index, configuration)
      expect(json_writer).to receive(:write).with(subject.index, configuration)
      expect(textile_writer).to receive(:write).with(subject.index, configuration)
      subject.write
    end
  end
end
