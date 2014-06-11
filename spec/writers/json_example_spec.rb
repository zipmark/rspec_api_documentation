# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::Writers::JsonExample do
  let(:configuration) { RspecApiDocumentation::Configuration.new }

  describe '#filename' do
    specify 'Hello!/ 世界' do |example|
      expect(described_class.new(example, configuration).filename).to eq("hello!_世界.json")
    end
  end
end
