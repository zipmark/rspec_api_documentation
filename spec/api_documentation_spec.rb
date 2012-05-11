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
      FileUtils.stub(:cp_r)
      subject.clear_docs

      File.directory?(configuration.docs_dir).should be_true
      File.exists?(test_file).should be_false
    end

    #it "copies in the stylesheets and javascripts" do
    #  subject.clear_docs
    #  p File.join(configuration.docs_dir, "javascripts")
    #  File.directory?(File.join(configuration.docs_dir, "javascripts")).should be_true
    #  File.exists?(File.join(configuration.docs_dir, "javascripts", "application.js")).should be_false
    #  File.directory?(File.join(configuration.docs_dir, "stylesheets")).should be_true
    #  File.exists?(File.join(configuration.docs_dir, "stylesheets", "application.css")).should be_false
    #end
  end

  describe "#document_example" do
    let(:metadata) {{ :should_document => true }}
    let(:group) { RSpec::Core::ExampleGroup.describe("test group") }
    let(:example) { group.example("test example", metadata) }
    let!(:wrapped_example) { RspecApiDocumentation::Example.new(example, configuration) }

    before do
      RspecApiDocumentation::Example.stub!(:new).and_return(wrapped_example)
    end

    it "should create a new wrapped example" do
      RspecApiDocumentation::Example.should_receive(:new).with(example, configuration).and_return(wrapped_example)
      documentation.document_example(example)
    end

    context "when the given example should be documented" do
      before { wrapped_example.stub!(:should_document?).and_return(true) }

      it "should add the wrapped example to the index" do
        documentation.document_example(example)
        documentation.index.examples.should eq([wrapped_example])
      end
    end

    context "when the given example should not be documented" do
      before { wrapped_example.stub!(:should_document?).and_return(false) }

      it "should not add the wrapped example to the index" do
        documentation.document_example(example)
        documentation.index.examples.should be_empty
      end
    end
  end

  describe "#writers" do
    class RspecApiDocumentation::HtmlWriter; end
    class RspecApiDocumentation::JsonWriter; end

    context "multiple" do
      before do
        configuration.format = [:html, :json]
      end

      it "should return the classes from format" do
        subject.writers.should == [RspecApiDocumentation::HtmlWriter, RspecApiDocumentation::JsonWriter]
      end
    end

    context "single" do
      before do
        configuration.format = :html
      end

      it "should return the classes from format" do
        subject.writers.should == [RspecApiDocumentation::HtmlWriter]
      end
    end
  end

  describe "#write" do
    let(:html_writer) { stub }
    let(:json_writer) { stub }

    before do
      subject.stub!(:writers => [html_writer, json_writer])
    end

    it "should write the docs in each format" do
      html_writer.should_receive(:write).with(subject.index, configuration)
      json_writer.should_receive(:write).with(subject.index, configuration)
      subject.write
    end
  end
end
