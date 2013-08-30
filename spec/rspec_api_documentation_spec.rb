require 'spec_helper'

describe RspecApiDocumentation do
  describe "#configuration" do
    it "should be a configuration" do
      RspecApiDocumentation.configuration.should be_a(RspecApiDocumentation::Configuration)
    end

    it "returns the same configuration every time" do
      RspecApiDocumentation.configuration.should equal(RspecApiDocumentation.configuration)
    end
  end

  describe "#configure" do
    let(:configuration) { double(:confiugration) }

    before do
      RspecApiDocumentation.stub(:configuration).and_return(configuration)
    end

    it "should yield the configuration to the block" do
      configuration.should_receive(:foo)
      RspecApiDocumentation.configure do |config|
        config.foo
      end
    end
  end
end
