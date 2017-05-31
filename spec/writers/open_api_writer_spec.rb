# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::Writers::OpenApiWriter do
  let(:index) { RspecApiDocumentation::Index.new }
  let(:configuration) { RspecApiDocumentation::Configuration.new }

  describe '.write' do
    let(:writer) { double(:writer) }

    it 'should build a new writer and write the docs' do
      allow(described_class).to receive(:new).with(index, configuration).and_return(writer)
      expect(writer).to receive(:write)
      described_class.write(index, configuration)
    end
  end
end
