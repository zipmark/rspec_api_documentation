# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::Views::HtmlExample do
  let(:metadata) { { :resource_name => "Orders" } }
  let(:group) { RSpec::Core::ExampleGroup.describe("Orders", metadata) }
  let(:rspec_example) { group.example("Ordering a cup of coffee") {} }
  let(:rad_example) do
    RspecApiDocumentation::Example.new(rspec_example, configuration)
  end
  let(:index) { RspecApiDocumentation::Index.new }
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:html_example) { described_class.new(index, rad_example, configuration) }

  specify "the directory is 'orders'" do
    expect(html_example.dirname).to eq("orders")
  end

  it "should have downcased filename" do
    expect(html_example.filename).to eq("ordering_a_cup_of_coffee.html")
  end

  describe "multi charctor example name" do
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
