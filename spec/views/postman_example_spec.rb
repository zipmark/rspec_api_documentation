require 'spec_helper'

describe RspecApiDocumentation::Views::PostmanRequestExample do
  let(:metadata) do
    { resource_name: 'Orders',
      parameters:
        [
          {name: 'type', required: false, description: 'decaf or regular'},
          {name: 'size', required: true, description: 'cup size' }
        ],
      route: '/orders',
      method: 'get'
    }
  end
  let(:group) { RSpec::Core::ExampleGroup.describe('', metadata) }
  let(:description) { 'Ordering a cup of coffee' }
  let(:rspec_example) { group.example(description) {} }
  let(:rad_example) do
    RspecApiDocumentation::Example.new(rspec_example, configuration)
  end
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:postman_example) { described_class.new(rad_example) }

  let(:content_type) { 'application/json' }
  let(:body_content) { '{}' }
  let(:requests) do
    [{
       request_body: body_content,
       request_headers: {
         "Content-Type" => content_type
       },
       request_content_type: ""
     }]
  end

  before do
    rspec_example.metadata[:requests] = requests
  end

  subject(:view) { postman_example }

  describe '#populate_query' do
    it 'populates parameters' do
      expect(subject.populate_query).to eq [{ key: 'type',
                                              equals: true,
                                              description: 'decaf or regular'
                                            },
                                            {
                                              key: 'size',
                                              equals: true,
                                              description: 'Required. cup size'
                                            }]
    end
  end

  describe '#content_type' do
    it 'parses content type' do
      expect(subject.content_type).to eq({ key: 'Content-Type', value: 'application/json' })
    end
  end

  describe '#as_json' do
    context 'when the example is for POST' do
      let(:metadata) do
        { resource_name: 'Orders',
          route: '/orders',
          method: 'post'
        }
      end
      let(:body_content) { "{ \"customer_name\": \"FooBar\" }" }

      it 'returns expected hash with correct data' do
        expected_hash = {
          name: description,
          request: {
            method: 'POST',
            header: [{ key: 'Content-Type', value: content_type }],
            body: { mode: 'raw', raw: body_content },
            url: {
              host: ['{{application_url}}'],
              path: ['orders'],
              query: [],
              variable: []
            },
            description: nil,
          },
          response: []
        }
        expect(subject.as_json).to eq expected_hash
      end
    end

    context 'when the example is for GET' do
      it 'returns expected hash with correct data' do
        expected_hash = {
          name: description,
          request: {
            method: 'GET',
            header: [{ key: 'Content-Type', value: content_type }],
            body: { mode: 'raw', raw: body_content },
            url: {
              host: ['{{application_url}}'],
              path: ['orders'],
              query: [{ key: 'type',
                        equals: true,
                        description: 'decaf or regular'
                      },
                      {
                        key: 'size',
                        equals: true,
                        description: 'Required. cup size'
                      }],
              variable: []
            },
            description: nil,
          },
          response: []
        }
        expect(subject.as_json).to eq expected_hash
      end
    end
  end
end