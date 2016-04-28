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

  describe '#curl_with_linebreaks' do
    subject { slate_example.curl_with_linebreaks }

    before(:each) { allow(slate_example).to receive(:requests).and_return requests }

    context 'marshaling' do
      let(:requests) { [{curl: 'One'}, {curl: "Two \nThree" }, {curl: 'Four   '}] }

      it 'joins all the Curl requests with linebreaks, stripping trailing whitespace' do
        expect(subject).to be == [
          'One', 'Two', 'Three', 'Four'
        ].join('<br>')
      end
    end

    context 'escaping' do
      let(:requests) { [{curl: string}] }

      context 'spaces' do
        let(:string) { 'a b' }

        it 'replaces them with nonbreaking spaces' do
          expect(subject).to be == 'a&nbsp;b'
        end
      end

      context 'tabs' do
        let(:string) { "a\tb" }

        it 'replaces them with two nonbreaking spaces' do
          expect(subject).to be == 'a&nbsp;&nbsp;b'
        end
      end

      context 'backslashes' do
        let(:string) { 'a\\b'}

        it 'replaces them with an HTML entity' do
          expect(subject).to be == 'a&#92;b'
        end
      end
    end
  end

  describe '#explanation_with_linebreaks' do
    it 'returns the explanation with HTML linebreaks' do
      explanation = "Line 1\nLine 2\nLine 3\Line 4"
      allow(slate_example).to receive(:explanation).and_return explanation
      expect(slate_example.explanation_with_linebreaks).to be == explanation.gsub("\n", "<br>\n")
    end
  end
end
