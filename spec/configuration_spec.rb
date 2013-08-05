require 'spec_helper'

describe RspecApiDocumentation::Configuration do
  let(:parent) { nil }
  let(:configuration) { RspecApiDocumentation::Configuration.new(parent) }

  subject { configuration }

  its(:parent) { should equal(parent) }
  its(:settings) { should == {} }
  its(:groups) { should == [] }

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

    context "when Rails is defined" do
      let(:rails_root) { Pathname.new("tmp") }
      let(:rails_app) { double(:rails_app) }

      before { Rails = double(:application => rails_app, :root => rails_root) }
      after { Object.send(:remove_const, :Rails) }

      its(:docs_dir) { should == rails_root.join("doc", "api") }
      its(:app) { should == rails_app }
    end

    its(:docs_dir) { should == Pathname.new("doc/api") }
    its(:format) { should == :html }
    its(:template_path) { should == default_template_path }
    its(:filter) { should == :all }
    its(:exclusion_filter) { should be_nil }
    its(:app) { should be_nil }
    its(:curl_host) { should be_nil }
    its(:keep_source_order) { should be_false }
    its(:api_name) { should == "API Documentation" }
  end

  describe "#define_groups" do
    it "should take a block" do
      called = false
      subject.define_group(:foo) { called = true }
      called.should eq(true)
    end

    it "should yield a sub-configuration" do
      subject.define_group(:foo) do |config|
        config.should be_a(described_class)
        config.parent.should equal(subject)
      end
    end

    it "should set the sub-configuration filter" do
      subject.define_group(:foo) do |config|
        config.filter.should eq(:foo)
      end
    end

    it "should inherit its parents configurations" do
      subject.format = :json
      subject.define_group(:sub) do |config|
        config.format.should == :json
      end
    end

    it "should scope the documentation directory" do
      subject.define_group(:sub) do |config|
        config.docs_dir.should == subject.docs_dir.join('sub')
      end
    end
  end

  it { should be_a(Enumerable) }

  it "should enumerate through recursively and include self" do
    configs = [subject]
    subject.define_group(:sub1) do |config|
      configs << config
      config.define_group(:sub2) do |config|
        configs << config
        config.define_group(:sub3) do |config|
          configs << config
        end
      end
    end
    subject.to_a.should eq(configs)
  end

  describe "#groups" do
    it "should list all of the defined groups" do
      subject.define_group(:sub) do |config|
      end

      subject.groups.should have(1).group
    end
  end
end
