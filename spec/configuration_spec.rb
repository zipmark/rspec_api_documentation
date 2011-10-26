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

    it "should allow the default setting to be a lambda" do
      RspecApiDocumentation::Configuration.add_setting :another_setting, :default => lambda { |config| config.new_setting }
      configuration.another_setting.should == "default"
    end
  end

  describe "default settings" do
    let(:default_example_template) do
      filepath = File.join(File.dirname(__FILE__), '..', 'templates', 'example_template.html')
      File.read(filepath)
    end
    let(:default_index_template) do
      filepath = File.join(File.dirname(__FILE__), '..', 'templates', 'index_template.html')
      File.read(filepath)
    end

    its(:docs_dir) { should == Rails.root.join("docs") }
    its(:public_docs_dir) { should == Rails.root.join("public", "docs") }
    its(:private_example_link) { should == "{{ link }}" }
    its(:public_example_link) { should == "/docs/{{ link }}" }
    its(:private_index_extension) { should == "html" }
    its(:public_index_extension) { should == "html" }
    its(:example_extension) { should == "html" }
    its(:example_template) { should == default_example_template }
    its(:index_template) { should == default_index_template }

    its(:settings) { should == {} }
  end
end
