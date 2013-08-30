# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::Views::HtmlExample do
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
