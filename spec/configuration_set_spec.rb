require 'spec_helper'

describe RspecApiDocumentation::ConfigurationSet do
  it "should respond to any method" do
    expect {
      subject.foo
      subject.bar
      subject.baz
      subject.quux
    }.not_to raise_error
  end

  it "should take block" do
    shibboleth = stub
    subject.foo { shibboleth }.should equal(shibboleth)
  end

  it "should yield a new configuration to the block" do
    subject.foo do |config|
      config.should be_a(RspecApiDocumentation::Configuration)
    end
  end

  describe "#configurations" do
    let(:configuration) { stub }

    before do
      RspecApiDocumentation::Configuration.stub!(:new).and_return(configuration)
    end

    it "save the yielded configurations indexed by name" do
      subject.foo {}
      subject.configurations[:foo].should equal(configuration)
    end
  end
end
