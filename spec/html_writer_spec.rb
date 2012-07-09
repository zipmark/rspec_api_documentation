# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::HtmlWriter do
  let(:index) { RspecApiDocumentation::Index.new }
  let(:configuration) { RspecApiDocumentation::Configuration.new }

  describe ".write" do
    let(:writer) { stub }

    it "should build a new writer and write the docs" do
      described_class.stub!(:new).with(index, configuration).and_return(writer)
      writer.should_receive(:write)
      described_class.write(index, configuration)
    end
  end

  describe "#write" do
    let(:writer) { described_class.new(index, configuration) }

    before do
      template_dir = File.join(configuration.template_path, "rspec_api_documentation")
      FileUtils.mkdir_p(template_dir)
      File.open(File.join(template_dir, "html_index.mustache"), "w+") { |f| f << "{{ mustache }}" }
      FileUtils.mkdir_p(configuration.docs_dir)
    end

    it "should write the index" do
      writer.write
      index_file = File.join(configuration.docs_dir, "index.html")
      File.exists?(index_file).should be_true
    end
  end
end

describe RspecApiDocumentation::HtmlExample do
  let(:metadata) { {} }
  let(:group) { RSpec::Core::ExampleGroup.describe("Orders", metadata) }
  let(:example) { group.example("Ordering a cup of coffee") {} }
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:html_example) { described_class.new(example, configuration) }

  it "should have downcased filename" do
    html_example.filename.should == "ordering_a_cup_of_coffee.html"
  end

  describe "multi charctor example name" do
    let(:label) { "コーヒーが順番で並んでいること" }
    let(:example) { group.example(label) {} }

    it "should have downcased filename" do
      filename = Digest::MD5.new.update(label).to_s
      html_example.filename.should == filename + ".html"
    end
  end
end
