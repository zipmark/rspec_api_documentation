require 'spec_helper'

describe RspecApiDocumentation::TestServer do
  let(:test_server) { described_class.new(self) }

  subject { test_server }

  its(:session) { should equal(self) }
  its(:example) { should equal(example) }
end
