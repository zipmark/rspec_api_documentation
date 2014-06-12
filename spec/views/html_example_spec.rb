# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::Views::HtmlExample do
  let(:metadata) { {} }
  let(:group) { RSpec::Core::ExampleGroup.describe("Orders", metadata) }
  let(:example) { group.example("Ordering a cup of coffee") {} }
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:html_example) { described_class.new(example, configuration) }

  it "should have downcased filename" do
    expect(html_example.filename).to eq("ordering_a_cup_of_coffee.html")
  end

  describe "multi charctor example name" do
    let(:label) { "Coffee / Teaが順番で並んでいること" }
    let(:example) { group.example(label) {} }

    it "should have downcased filename" do
      expect(html_example.filename).to eq("coffee__teaが順番で並んでいること.html")
    end
  end
end
