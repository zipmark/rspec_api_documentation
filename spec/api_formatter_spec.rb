require 'spec_helper'

describe RspecApiDocumentation::ApiFormatter do
  let(:metadata) { {} }
  let(:group) { RSpec::Core::ExampleGroup.describe("Orders", metadata) }
  let(:output) { StringIO.new }
  let(:formatter) { RspecApiDocumentation::ApiFormatter.new(output) }

  describe "generating documentation" do
    include FakeFS::SpecHelpers

    before do
      RspecApiDocumentation.documentations.each do |configuration|
        configuration.stub(
          :clear_docs => nil,
          :document_example => nil,
          :write => nil
        )
      end
    end

    it "should clear all docs on start" do
      RspecApiDocumentation.documentations.each do |configuration|
        configuration.should_receive(:clear_docs)
      end

      formatter.start(0)
    end

    it "should document passing examples" do
      example = group.example("Ordering a cup of coffee") {}

      RspecApiDocumentation.documentations.each do |configuration|
        configuration.should_receive(:document_example).with(example)
      end

      formatter.example_passed(example)
    end

    it "should write the docs on stop" do
      RspecApiDocumentation.documentations.each do |configuration|
        configuration.should_receive(:write)
      end

      formatter.stop
    end
  end

  describe "output" do
    before do
      # don't do any work
      RspecApiDocumentation.stub(:documentations).and_return([])
    end

    context "with passing examples" do
      before do
        group.example("Ordering a cup of coffee") {}
        group.example("Updating an order") {}
        group.example("Viewing an order") {}
      end

      it "should list the generated docs" do
        group.run(formatter)
        output.string.split($/).should eq([
          "Generating API Docs",
          "  Orders",
          "    * Ordering a cup of coffee",
          "    * Updating an order",
          "    * Viewing an order"
        ])
      end
    end

    context "with failing examples" do
      before do
        group.example("Ordering a cup of coffee") {}
        group.example("Updating an order") { true.should eq(false) }
        group.example("Viewing an order") { true.should eq(false) }
      end

      it "should indicate failures" do
        group.run(formatter)
        output.string.split($/).should eq([
          "Generating API Docs",
          "  Orders",
          "    * Ordering a cup of coffee",
          "    ! Updating an order (FAILED)",
          "    ! Viewing an order (FAILED)"
        ])
      end
    end
  end
end
