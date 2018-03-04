require 'spec_helper'


describe RspecApiDocumentation::Views::PostmanRequestExample do
  let(:metadata) { { resource_name: 'Orders' } }
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
       request_content_type: "",
     }]
  end

  before do
    rspec_example.metadata[:requests] = requests
  end

  describe '#populate_query' do
    it 'just does something' do
      puts rspec_example.inspect
      puts rad_example.inspect
      expect(postman_example).to eq true
    end
  end
end