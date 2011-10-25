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

  it { should be_a(Enumerable) }

  it "should take block" do
    called = false
    subject.foo { called = true }
    called.should be_true
  end

  it "should yield a new configuration to the block" do
    subject.foo do |config|
      config.should be_a(RspecApiDocumentation::Configuration)
    end
  end

  describe "#configurations" do
    let(:configuration) { stub }
    let(:documentation) { stub }

    before do
      RspecApiDocumentation::Configuration.stub!(:new).and_return(configuration)
      RspecApiDocumentation::ApiDocumentation.stub!(:new).with(configuration).and_return(documentation)
    end

    it "create an ApiDocumentation with the yielded Configuration and index it by name" do
      subject.foo {}
      subject.configurations[:foo].should equal(documentation)
    end
  end

  describe "#each" do
    let(:configurations) { [stub, stub] }
    let(:documentations) { [stub, stub] }

    before do
      RspecApiDocumentation::Configuration.stub!(:new).and_return(*configurations)
      RspecApiDocumentation::ApiDocumentation.stub!(:new).and_return(*documentations)
    end

    it "should enumerate over the ApiDocumentation instances" do
      subject.foo {}
      subject.bar {}

      index = 0
      subject.each do |documentation|
        documentations[index].should equal(documentation)
        index += 1
      end
      index.should eq(2)
    end
  end
end
