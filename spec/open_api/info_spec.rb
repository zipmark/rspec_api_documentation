require 'spec_helper'

describe RspecApiDocumentation::OpenApi::Info do
  let(:node) { RspecApiDocumentation::OpenApi::Info.new }
  subject { node }

  describe "default settings" do
    its(:title) { should == 'OpenAPI Specification' }
    its(:version) { should == '1.0.0' }
  end
end
