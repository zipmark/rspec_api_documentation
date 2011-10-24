require 'spec_helper'

describe RspecApiDocumentation do
  let(:configuration_set) { stub }

  describe "#configurations" do
    before do
      RspecApiDocumentation::ConfigurationSet.stub(:new).and_return(configuration_set, nil)
    end

    it "should be a configuration set" do
      2.times {
        RspecApiDocumentation.configurations.should equal(configuration_set)
      }
    end
  end

  describe "#configure" do
    before do
      RspecApiDocumentation.stub!(:configurations).and_return(configuration_set)
    end

    it "should take a block" do
      shibboleth = stub
      RspecApiDocumentation.configure { shibboleth }.should equal(shibboleth)
    end

    it "should yield the configuration set to the block" do
      RspecApiDocumentation.configure do |format|
        format.should equal(configuration_set)
      end
    end
  end
end
