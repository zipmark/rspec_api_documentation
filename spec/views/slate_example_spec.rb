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

end
