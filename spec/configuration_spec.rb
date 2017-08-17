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
      expect(configuration).to respond_to(:new_setting)
      expect(configuration).to respond_to(:new_setting=)
    end

    it 'should allow setting a default' do
      RspecApiDocumentation::Configuration.add_setting :new_setting, :default => "default"
      expect(configuration.new_setting).to eq("default")
    end

    it "should allow the default setting to be a lambda" do
      RspecApiDocumentation::Configuration.add_setting :another_setting, :default => lambda { |config| config.new_setting }
      expect(configuration.another_setting).to eq("default")
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
    its(:curl_headers_to_filter) { should be_nil }
    its(:curl_host) { should be_nil }
    its(:keep_source_order) { should be_falsey }
    its(:api_name) { should == "API Documentation" }
    its(:api_explanation) { should be_nil }
    its(:client_method) { should == :client }
    its(:io_docs_protocol) { should == "http" }
    its(:request_headers_to_include) { should be_nil }
    its(:response_headers_to_include) { should be_nil }
    its(:html_embedded_css_file) { should be_nil }

    specify "post body formatter" do
      expect(configuration.request_body_formatter.call({ :page => 1})).to eq({ :page => 1 })
    end
  end

  describe "#define_groups" do
    it "should take a block" do
      called = false
      subject.define_group(:foo) { called = true }
      expect(called).to eq(true)
    end

    it "should yield a sub-configuration" do
      subject.define_group(:foo) do |config|
        expect(config).to be_a(described_class)
        expect(config.parent).to equal(subject)
      end
    end

    it "should set the sub-configuration filter" do
      subject.define_group(:foo) do |config|
        expect(config.filter).to eq(:foo)
      end
    end

    it "should inherit its parents configurations" do
      subject.format = :json
      subject.define_group(:sub) do |config|
        expect(config.format).to eq(:json)
      end
    end

    it "should scope the documentation directory" do
      subject.define_group(:sub) do |config|
        expect(config.docs_dir).to eq(subject.docs_dir.join('sub'))
      end
    end
  end

  it { expect(subject).to be_a(Enumerable) }

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
    expect(subject.to_a).to eq(configs)
  end

  describe "#groups" do
    it "should list all of the defined groups" do
      subject.define_group(:sub) do |config|
      end

      expect(subject.groups.count).to eq(1)
    end
  end
end
