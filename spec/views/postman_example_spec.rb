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
  let(:rspec_example) { group.example('Ordering a cup of coffee') {} }
  let(:rad_example) do
    RspecApiDocumentation::Example.new(rspec_example, configuration)
  end
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:postman_example) { described_class.new(rad_example) }

  let(:content_type) { "application/json" }
  let(:requests) do
    [{
       request_body: "{}",
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
    it 'something' do
      expected_hash = {
                        name: 'Ordering a cup of coffee',
                        request: {
                          method: 'GET',
                          header: [{ key: 'Content-Type', value: content_type }],
                          body: { mode: 'raw', raw: '{}'},
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