require 'spec_helper'

describe RspecApiDocumentation::Writers::JsonWriter do
  let(:index) { RspecApiDocumentation::Index.new }
  let(:configuration) { RspecApiDocumentation::Configuration.new }

  describe ".write" do
    let(:writer) { double(:writer) }

    it "should build a new writer and write the docs" do
      described_class.stub(:new).with(index, configuration).and_return(writer)
      writer.should_receive(:write)
      described_class.write(index, configuration)
    end
  end

  describe "#write" do
    let(:writer) { described_class.new(index, configuration) }

    before do
      FileUtils.mkdir_p(configuration.docs_dir)
    end

    it "should write the index" do
      writer.write
      index_file = File.join(configuration.docs_dir, "index.json")
      File.exists?(index_file).should be_true
    end
  end
end
