require 'spec_helper'

describe RspecApiDocumentation do
  describe "#configuration" do
    it "should be a configuration" do
      expect(RspecApiDocumentation.configuration).to be_a(RspecApiDocumentation::Configuration)
    end

    it "returns the same configuration every time" do
      expect(RspecApiDocumentation.configuration).to equal(RspecApiDocumentation.configuration)
    end
  end

  describe "#configure" do
    let(:configuration) { double(:confiugration) }

    before do
      allow(RspecApiDocumentation).to receive(:configuration).and_return(configuration)
    end

    it "should yield the configuration to the block" do
      allow(configuration).to receive(:foo)
      RspecApiDocumentation.configure do |config|
        config.foo
      end
    end
  end
end
