# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::Writers::JsonApiExample do
  let(:configuration) { RspecApiDocumentation::Configuration.new }

  describe "#dirname" do
    it "strips out leading slashes" do
      example = double(resource_name: "/test_string")
      json_example = described_class.new(example, configuration)
      expect(json_example.dirname).to eq "test_string"
    end

    it "does not strip out non-leading slashes" do
      example = double(resource_name: "test_string/test")
      json_example = described_class.new(example, configuration)
      expect(json_example.dirname).to eq "test_string/test"
    end
  end

  describe '#filename' do
    specify 'Hello!/ 世界' do |example|
      expect(described_class.new(example, configuration).filename).to eq("hello!_世界.json")
    end
  end
end
