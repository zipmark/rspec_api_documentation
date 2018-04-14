# -*- coding: utf-8 -*-
require 'spec_helper'

describe RspecApiDocumentation::Views::ApiBlueprintExample do
  let(:metadata) { { :resource_name => "Orders" } }
  let(:group) { RSpec::Core::ExampleGroup.describe("Orders", metadata) }
  let(:rspec_example) { group.example("Ordering a cup of coffee") {} }
  let(:rad_example) do
    RspecApiDocumentation::Example.new(rspec_example, configuration)
  end
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:html_example) { described_class.new(rad_example, configuration) }

  let(:content_type) { "application/json; charset=utf-8" }
  let(:requests) do
    [{
      request_body: "{}",
      request_headers: {
        "Content-Type" => content_type,
        "Another" => "header; charset=utf-8"
      },
      request_content_type: "",
      response_body: "{}",
      response_headers: {
        "Content-Type" => content_type,
        "Another" => "header; charset=utf-8"
      },
      response_content_type: ""
    }]
  end

  before do
    rspec_example.metadata[:requests] = requests
  end

  subject(:view) { described_class.new(rad_example, configuration) }

  describe '#requests' do
    describe 'request_content_type' do
      subject { view.requests[0][:request_content_type] }

      context 'when charset=utf-8 is present' do
        it "just strips that because it's the default for json" do
          expect(subject).to eq "application/json"
        end
      end

      context 'when charset=utf-16 is present' do
        let(:content_type) { "application/json; charset=utf-16" }

        it "keeps that because it's NOT the default for json" do
          expect(subject).to eq "application/json; charset=utf-16"
        end
      end
    end

    describe 'request_headers_text' do
      subject { view.requests[0][:request_headers_text] }

      context 'when Content-Type is present' do
        it "removes it" do
          expect(subject).to eq "Another: header; charset=utf-8"
        end
      end
    end

    describe 'response_content_type' do
      subject { view.requests[0][:response_content_type] }

      context 'when charset=utf-8 is present' do
        it "just strips that because it's the default for json" do
          expect(subject).to eq "application/json"
        end
      end

      context 'when charset=utf-16 is present' do
        let(:content_type) { "application/json; charset=utf-16" }

        it "keeps that because it's NOT the default for json" do
          expect(subject).to eq "application/json; charset=utf-16"
        end
      end
    end

    describe 'response_headers_text' do
      subject { view.requests[0][:response_headers_text] }

      context 'when Content-Type is present' do
        it "removes it" do
          expect(subject).to eq "Another: header; charset=utf-8"
        end
      end
    end
  end
end
