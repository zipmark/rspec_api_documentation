require 'spec_helper'

describe RspecApiDocumentation::Configuration do
  describe ".add_setting" do
    it 'should allow creating a new setting' do
      RspecApiDocumentation::Configuration.add_setting :new_setting
      config = RspecApiDocumentation::Configuration.new
      config.should respond_to(:new_setting)
      config.should respond_to(:new_setting=)
    end

    it 'should allow setting a default' do
      RspecApiDocumentation::Configuration.add_setting :new_setting, :default => "default"
      config = RspecApiDocumentation::Configuration.new
      config.new_setting.should == "default"
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
end
