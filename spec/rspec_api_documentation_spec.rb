require 'spec_helper'

describe RspecApiDocumentation do
  let(:configuration) { stub }

  describe "#configuration" do
    before do
      # if other tests call RspecApiDocumentation.configuration, the value will
      # already be cached. force it to nil for this test
      RspecApiDocumentation.instance_variable_set(:@configuration, nil)

      RspecApiDocumentation::Configuration.stub!(:new).and_return(configuration, nil)
    end

    it "should be a configuration" do
      RspecApiDocumentation.configuration.should equal(configuration)
    end

    it "returns the same configuration every time" do
      RspecApiDocumentation.configuration.should equal(RspecApiDocumentation.configuration)
    end
  end

  describe "#configure" do
    before do
      RspecApiDocumentation.stub!(:configuration).and_return(configuration)
    end

    it "should take a block" do
      called = false
      RspecApiDocumentation.configure { called = true }
      called.should be_true
    end

    it "should yield the configuration to the block" do
      RspecApiDocumentation.configure do |config|
        config.should equal(configuration)
      end
    end
  end
end
