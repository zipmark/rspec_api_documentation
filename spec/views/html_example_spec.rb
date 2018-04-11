# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::Views::HtmlExample do
  let(:metadata) { { :resource_name => "Orders" } }
  let(:group) { RSpec::Core::ExampleGroup.describe("Orders", metadata) }
  let(:description) { "Ordering a cup of coffee" }
  let(:rspec_example) { group.example(description) {} }
  let(:rad_example) do
    RspecApiDocumentation::Example.new(rspec_example, configuration)
  end
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:html_example) { described_class.new(rad_example, configuration) }

  specify "the directory is 'orders'" do
    expect(html_example.dirname).to eq("orders")
  end

  it "should have downcased filename" do
    expect(html_example.filename).to eq("ordering_a_cup_of_coffee.html")
  end

  context "when description contains special characters for Windows OS" do
    let(:description) { 'foo<>:"/\|?*bar' }

    it "removes them" do
      expect(html_example.filename).to eq("foobar.html")
    end
  end

  context "when resource name contains special characters for Windows OS" do
    let(:metadata) { { :resource_name => 'foo<>:"/\|?*bar' } }

    it "removes them" do
      expect(html_example.dirname).to eq("foobar")
    end
  end

  describe "multi-character example name" do
    let(:metadata) { { :resource_name => "オーダ" } }
    let(:label) { "Coffee / Teaが順番で並んでいること" }
    let(:rspec_example) { group.example(label) {} }

    specify "the directory is 'オーダ'" do
      expect(html_example.dirname).to eq("オーダ")
    end

    it "should have downcased filename" do
      expect(html_example.filename).to eq("coffee__teaが順番で並んでいること.html")
    end
  end
end
