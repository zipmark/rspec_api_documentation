require 'spec_helper'

describe RspecApiDocumentation::Index do
  let(:index) { RspecApiDocumentation::Index.new }

  subject { index }

  describe "#examples" do
    let(:examples) { [double(:example), double(:example)] }

    before do
      index.examples.push(*examples)
    end

    it "should contain all added examples" do
      expect(index.examples).to eq(examples)
    end
  end
end
