require 'spec_helper'

describe RspecApiDocumentation::Writers::JsonIodocsWriter do
  let(:index) { RspecApiDocumentation::Index.new }
  let(:configuration) { RspecApiDocumentation::Configuration.new }

  describe ".write" do
    let(:writer) { double(:writer) }

    it "should build a new writer and write the docs" do
      allow(described_class).to receive(:new).with(index, configuration).and_return(writer)
      expect(writer).to receive(:write)
      described_class.write(index, configuration)
    end
  end

  describe "#write" do
    let(:writer) { described_class.new(index, configuration) }

    before do
      allow(configuration.api_name).to receive(:parameterize).and_return("Name")
      FileUtils.mkdir_p(configuration.docs_dir)
    end

    it "should write the index" do
      writer.write
      index_file = File.join(configuration.docs_dir, "apiconfig.json")
      expect(File.exists?(index_file)).to be_truthy
    end
  end
end
