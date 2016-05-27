require 'spec_helper'

describe RspecApiDocumentation::Views::SlateExample do
  let(:metadata) { { :resource_name => "Orders" } }
  let(:group) { RSpec::Core::ExampleGroup.describe("Orders", metadata) }
  let(:rspec_example) { group.example("Ordering a cup of coffee") {} }
  let(:rad_example) do
    RspecApiDocumentation::Example.new(rspec_example, configuration)
  end
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:slate_example) { described_class.new(rad_example, configuration) }

  describe '#explanation_with_linebreaks' do
    it 'returns the explanation with HTML linebreaks' do
      explanation = "Line 1\nLine 2\nLine 3\Line 4"
      allow(slate_example).to receive(:explanation).and_return explanation
      expect(slate_example.explanation_with_linebreaks).to be == explanation.gsub("\n", "<br>\n")
    end
  end
end
