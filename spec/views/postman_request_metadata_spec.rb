require 'spec_helper'

describe RspecApiDocumentation::Views::PostmanRequestMetadata do
  let(:metadata) do
    { resource_name: 'Orders',
      parameters:
        [
          { name: 'type', required: false, description: 'decaf or regular' },
          { name: 'size', required: true, description: 'cup size' }
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
  let(:postman_metadata) { described_class.new(rad_example) }

  let(:content_type) { 'application/json' }
  let(:body_content) { '{}' }
  let(:requests) do
    [{
       request_body: body_content,
       request_headers: {
         "Content-Type" => content_type
       },
       request_content_type: "",
       request_query_parameters: { type: 'decaf', size: 'tall' }
     }]
  end

  before do
    rspec_example.metadata[:requests] = requests
  end

  subject(:view_helper) { postman_metadata }

  describe '#query_in_url' do
    it 'populates parameters' do
      expect(subject.query_in_url).to eq [{
                                            key: 'type',
                                            value: '',
                                            equals: true,
                                            description: 'decaf or regular',
                                            disabled: true
                                          },
                                          {
                                            key: 'size',
                                            value: '',
                                            equals: true,
                                            description: 'Required. cup size',
                                            disabled: false
                                          }]
    end
  end

  describe '#content_type' do
    it 'parses content type' do
      expect(subject.content_type).to eq({ key: 'Content-Type', value: 'application/json' })
    end
  end

  describe '#body' do
    context 'when content type includes application/json' do
      let(:body_content) { "{ \"customer_name\": \"FooBar\" }" }

      it 'returns raw mode hash' do
        expect(subject.body).to eq({ mode: 'raw', raw: body_content })
      end
    end

    context 'when content type is w-www-form-urlencoded' do
      let(:content_type) { 'application/w-www-form-urlencoded' }
      let(:body_content) { "type=decaf&size=regular"}

      it 'returns urlencoded hash' do
        expect(subject.body).to eq({ mode: 'urlencoded',
                                     urlencoded: [
                                       {
                                         key: 'type',
                                         value: '',
                                         description: 'decaf or regular',
                                         type: 'text',
                                         disabled: true
                                       },
                                       {
                                         key: 'size',
                                         value: '',
                                         description: 'Required. cup size',
                                         type: 'text',
                                         disabled: false
                                       }]
                                   })
      end
    end
  end

  describe '#variables_for_url' do
    context 'when route has a variable' do
      let(:metadata) do
        { resource_name: 'Orders',
          parameters:
            [
              { name: 'id', required: true, description: 'Order ID' },
              { name: 'type', required: false, description: 'decaf or regular' },
              { name: 'size', required: true, description: 'cup size' }
            ],
          route: '/orders/:id',
          method: 'get'
        }
      end

      it 'can populate variable for url' do
        expect(subject.variables_for_url).to eq([{ key: 'id',
                                                   value: '',
                                                   description: 'Required. Order ID',
                                                   disabled: false }])
      end
    end
  end
end
