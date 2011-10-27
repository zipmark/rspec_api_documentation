require 'spec_helper'

describe RspecApiDocumentation::ApiDocumentation do
  let(:format) { :html }
  let(:configuration) { RspecApiDocumentation::Configuration.new(format) }
  let(:documentation) { RspecApiDocumentation::ApiDocumentation.new(configuration) }

  subject { documentation }

  its(:configuration) { should equal(configuration) }
  its(:private_index) { should be_a(RspecApiDocumentation::Index) }
  its(:public_index) { should be_a(RspecApiDocumentation::Index) }
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
    let(:metadata) {{ :should_document => true, :public? => false }}
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

      it "should add the wrapped example to the list of examples" do
        documentation.document_example(example)
        documentation.examples.last.should equal(wrapped_example)
      end

      it "should add the wrapped example to the private index" do
        documentation.private_index.should_receive(:add_example).with(wrapped_example)
        documentation.document_example(example)
      end

      context "when the given example should be publicly documented" do
        before { wrapped_example.stub!(:public? => true) }

        it "should add the wrapped example to the public index" do
          documentation.public_index.should_receive(:add_example).with(wrapped_example)
          documentation.document_example(example)
        end
      end

      context "when the given example should not be publicly documented" do
        before { wrapped_example.stub!(:public? => false) }

        it "should not add the wrapped example to the public index" do
          documentation.public_index.should_not_receive(:add_example)
          documentation.document_example(example)
        end
      end
    end

    context "when the given example should not be documented" do
      before { wrapped_example.stub!(:should_document?).and_return(false) }

      it "should not add the wrapped example to the list of examples" do
        documentation.document_example(example)
        documentation.examples.should_not include(wrapped_example)
      end

      it "should not add the wrapped example to the private index" do
        documentation.private_index.should_not_receive(:add_example)
        documentation.document_example(example)
      end

      it "should not add the wrapped example to the public index" do
        documentation.public_index.should_not_receive(:add_example)
        documentation.document_example(example)
      end
    end
  end

  describe "#write_private_index" do
    include FakeFS::SpecHelpers

    let(:index) { RspecApiDocumentation::Index.new(configuration) }

    before do
      documentation.stub!(:private_index).and_return(index)
      index.stub(:render).and_return('rendered content')
    end

    it "should render the index" do
      index.should_receive(:render)
      documentation.write_private_index
    end

    it "should write the rendered content to the correct file" do
      documentation.write_private_index
      File.read(configuration.docs_dir.join('index.html')).should eq('rendered content')
    end
  end

  describe "#write_public_index" do
    include FakeFS::SpecHelpers

    let(:index) { RspecApiDocumentation::Index.new(configuration) }

    before do
      documentation.stub!(:public_index).and_return(index)
      index.stub(:render).and_return('rendered content')
    end

    it "should render the index" do
      index.should_receive(:render)
      documentation.write_public_index
    end

    it "should write the rendered content to the correct file" do
      documentation.write_public_index
      File.read(configuration.public_docs_dir.join('index.html')).should eq('rendered content')
    end
  end

  describe "#write_examples" do
    let(:examples) { Array.new(2) { stub } }

    before do
      documentation.stub!(:examples).and_return(examples)
    end

    it "should write each example" do
      examples.each do |example|
        documentation.should_receive(:write_example).with(example)
      end
      documentation.write_examples
    end
  end

  describe "#write_example" do
    include FakeFS::SpecHelpers

    let(:metadata) { stub }
    let(:wrapped_example) { stub(:metadata => metadata) }

    before do
      wrapped_example.stub!(:dirname).and_return('test_dir')
      wrapped_example.stub!(:filename).and_return('test_file.html')
      wrapped_example.stub!(:render).and_return('rendered content')

      documentation.clear_docs
    end

    it "should render the example" do
      wrapped_example.should_receive(:render)
      documentation.write_example(wrapped_example)
    end

    it "should write the rendered content to the correct file" do
      documentation.write_example(wrapped_example)
      File.read(configuration.docs_dir.join('test_dir', 'test_file.html')).should eq('rendered content')
    end
  end

  describe "#symlink_public_examples" do
    include FakeFS::SpecHelpers

    let(:example) { stub(:dirname => "dir", :filename => "file") }
    let(:public_index) { stub(:examples => [example]) }

    before do
      configuration.docs_dir = "doc"
      configuration.public_docs_dir = "pub"
      documentation.stub!(:public_index).and_return(public_index)

      FileUtils.mkdir_p("doc/dir")
      File.open("doc/dir/file", "w+") { |f| f.write "Hello, world!" }
    end

    it "should create the public doc's example group directories" do
      documentation.symlink_public_examples
      File.directory?("pub/dir")
    end

    it "should link the documentation" do
      documentation.symlink_public_examples
      File.read("pub/dir/file").should eq("Hello, world!")
    end
  end
end
