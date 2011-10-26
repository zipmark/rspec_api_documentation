require 'spec_helper'

describe RspecApiDocumentation::Configuration do
  let(:format) { :blah }
  let(:configuration) { RspecApiDocumentation::Configuration.new(format) }

  subject { configuration }

  its(:format) { should equal(format) }

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
    let(:default_template_path) { File.expand_path("../../templates", __FILE__) }

    its(:docs_dir) { should == Rails.root.join("docs") }
    its(:public_docs_dir) { should == Rails.root.join("public", "docs") }
    its(:private_index_extension) { should == format }
    its(:public_index_extension) { should == format }
    its(:example_extension) { should == format }
    its(:template_extension) { should == format }
    its(:template_path) { should == default_template_path }

    its(:settings) { should == {} }
  end
end
