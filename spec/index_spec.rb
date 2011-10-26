require 'spec_helper'

describe RspecApiDocumentation::Index do
  let(:foo_example_group) { RSpec::Core::ExampleGroup.describe("Foo", :resource_name => "Foo", :document => true) }
  let(:bar_example_group) { RSpec::Core::ExampleGroup.describe("Bar", :resource_name => "Bar", :document => true) }
  let(:foo_examples) { Array.new(2) { |i| foo_example_group.example("Foo #{i}") {} } }
  let(:bar_examples) { Array.new(2) { |i| bar_example_group.example("Bar #{i}") {} } }
  let(:examples) { foo_examples + bar_examples }
  let(:configuration) { RspecApiDocumentation::Configuration.new(:html) }
  let(:index) { RspecApiDocumentation::Index.new(configuration) }

  subject { index }

  it { should be_a(Mustache) }

  its(:configuration) { should equal(configuration) }

  describe "#add_example" do
    let(:wrapped_example) { stub(:index= => nil) }

    before do
      RspecApiDocumentation::Example.stub!(:new).with(examples.first, configuration).and_return(wrapped_example)
    end

    it "should wrap the given example and add it to examples" do
      index.add_example(examples.first)
      index.examples.last.should equal(wrapped_example)
    end
  end

  describe "#sections" do
    it "should have one for each documented resource" do
      wrapped_foo_examples = foo_examples.map { |example| RspecApiDocumentation::Example.new(example, configuration) }
      wrapped_bar_examples = bar_examples.map { |example| RspecApiDocumentation::Example.new(example, configuration) }

      RspecApiDocumentation::Example.stub!(:new).and_return(*(wrapped_foo_examples + wrapped_bar_examples))

      foo_examples.each { |example| index.add_example(example) }
      bar_examples.each { |example| index.add_example(example) }

      index.sections.should eq(
        [
          {:resource_name => "Foo", :examples => wrapped_foo_examples},
          {:resource_name => "Bar", :examples => wrapped_bar_examples}
        ]
      )
    end
  end

  describe "#examples" do
    let(:wrapped_examples) { [stub(:index= => nil)] * examples.count }

    before do
      RspecApiDocumentation::Example.stub!(:new).and_return(*wrapped_examples)
      examples.each { |example| index.add_example(example) }
    end

    it "should return the added examples, wrapped" do
      index.examples.should eq(wrapped_examples)
    end
  end
end
