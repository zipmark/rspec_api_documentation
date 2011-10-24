require 'spec_helper'

describe RspecApiDocumentation::Configuration do
  let(:configuration) { RspecApiDocumentation::Configuration.new }

  subject { configuration }

  describe ".add_setting" do
    it 'should allow creating a new setting' do
      RspecApiDocumentation::Configuration.add_setting :new_setting
      configuration.should respond_to(:new_setting)
      configuration.should respond_to(:new_setting=)
    end

    it 'should allow setting a default' do
      RspecApiDocumentation::Configuration.add_setting :new_setting, :default => "default"
      configuration.new_setting.should == "default"
    end
  end

  describe "default settings" do
    its(:docs_dir) { should == Rails.root.join("docs") }
    its(:public_docs_dir) { should == Rails.root.join("public", "docs") }
    its(:private_example_link) { should == "{{ link }}" }
    its(:public_example_link) { should == "/docs/{{ link }}" }
    its(:private_index_extension) { should == "html" }
    its(:public_index_extension) { should == "html" }

    its(:settings) { should == {} }
  end

  describe "#clear_docs" do
    include FakeFS::SpecHelpers

    it "should rebuild the docs directory" do
      test_file = configuration.docs_dir.join("test")
      FileUtils.mkdir_p configuration.docs_dir
      FileUtils.touch test_file

      configuration.clear_docs

      File.directory?(configuration.docs_dir).should be_true
      File.exists?(test_file).should be_false
    end

    it "should rebuild the public docs directory" do
      test_file = configuration.public_docs_dir.join("test")
      FileUtils.mkdir_p configuration.public_docs_dir
      FileUtils.touch test_file

      configuration.clear_docs

      File.directory?(configuration.public_docs_dir).should be_true
      File.exists?(test_file).should be_false
    end
  end
end
