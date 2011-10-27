require 'spec_helper'

describe RspecApiDocumentation::Index do
  let(:configuration) { RspecApiDocumentation::Configuration.new(:html) }
  let(:index) { RspecApiDocumentation::Index.new(configuration) }

  subject { index }

  it { should be_a(Mustache) }

  its(:configuration) { should equal(configuration) }
  its(:template_path) { should eq(configuration.template_path) }
  its(:template_extension) { should eq(configuration.template_extension) }

  describe "#add_example" do
    let(:example) { stub }

    it "should add the example to #examples" do
      index.add_example(example)
      index.examples.last.should equal(example)
    end
  end

  describe "#sections" do
    let(:foo_examples) { Array.new(2) { stub(:resource_name => "Foo") } }
    let(:bar_examples) { Array.new(2) { stub(:resource_name => "Bar") } }

    it "should have one for each documented resource" do
      foo_examples.each { |example| index.add_example(example) }
      bar_examples.each { |example| index.add_example(example) }

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
      examples.each { |example| index.add_example(example) }
    end

    it "should contain all added examples" do
      index.examples.should eq(examples)
    end
  end
end
