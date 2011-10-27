require 'spec_helper'

describe RspecApiDocumentation::Index do
  let(:configuration) { RspecApiDocumentation::Configuration.new(:html) }
  let(:index) { RspecApiDocumentation::Index.new(configuration) }

  subject { index }

  it { should be_a(Mustache) }

  its(:configuration) { should equal(configuration) }
  its(:template_path) { should eq(configuration.template_path) }
  its(:template_extension) { should eq(configuration.template_extension) }

  describe "#sections" do
    let(:foo_examples) { Array.new(2) { stub(:resource_name => "Foo") } }
    let(:bar_examples) { Array.new(2) { stub(:resource_name => "Bar") } }

    it "should have one for each documented resource" do
      index.examples.push(*foo_examples)
      index.examples.push(*bar_examples)

      index.sections.should eq(
        [
          {:resource_name => "Foo", :examples => foo_examples},
          {:resource_name => "Bar", :examples => bar_examples}
        ]
      )
    end
  end

  describe "#examples" do
    let(:examples) { [stub, stub] }

    before do
      index.examples.push(*examples)
    end

    it "should contain all added examples" do
      index.examples.should eq(examples)
    end
  end
end
