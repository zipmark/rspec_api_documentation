require 'spec_helper'

describe RspecApiDocumentation::ApiDocumentation do
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:documentation) { RspecApiDocumentation::ApiDocumentation.new(configuration) }

  subject { documentation }

  its(:configuration) { should equal(configuration) }
  its(:examples) { should be_empty }

  describe "#clear_docs" do
    include FakeFS::SpecHelpers

    it "should rebuild the docs directory" do
      test_file = configuration.docs_dir.join("test")
      FileUtils.mkdir_p configuration.docs_dir
      FileUtils.touch test_file

      subject.clear_docs

      File.directory?(configuration.docs_dir).should be_true
      File.exists?(test_file).should be_false
    end

    it "should rebuild the public docs directory" do
      test_file = configuration.public_docs_dir.join("test")
      FileUtils.mkdir_p configuration.public_docs_dir
      FileUtils.touch test_file

      subject.clear_docs

      File.directory?(configuration.public_docs_dir).should be_true
      File.exists?(test_file).should be_false
    end
  end

  describe "#document_example" do
    let(:example) { stub }
    let(:wrapped_example) { stub(:should_document? => true) }

    before do
      RspecApiDocumentation::Example.stub!(:new).and_return(wrapped_example)
    end

    it "should create a new wrapped example" do
      RspecApiDocumentation::Example.should_receive(:new).with(example).and_return(wrapped_example)
      documentation.document_example(example)
    end

    context "when the given example should be documented" do
      before { wrapped_example.stub!(:should_document?).and_return(true) }

      it "should add the wrapped example to the list of examples" do
        documentation.document_example(example)
        documentation.examples.last.should equal(wrapped_example)
      end
    end

    context "when the given example should not be documented" do
      before { wrapped_example.stub!(:should_document?).and_return(false) }

      it "should not add the wrapped example to the list of examples" do
        documentation.document_example(example)
        documentation.examples.should_not include(wrapped_example)
      end
    end
  end
end
