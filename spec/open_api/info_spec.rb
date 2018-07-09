require 'spec_helper'

describe RspecApiDocumentation::OpenApi::Info do
  let(:node) { RspecApiDocumentation::OpenApi::Info.new }
  subject { node }

  describe "default settings" do
    class RspecApiDocumentation::OpenApi::Contact; end
    class RspecApiDocumentation::OpenApi::License; end

    its(:title) { should == 'OpenAPI Specification' }
    its(:description) { should == 'This is a sample server Petstore server.' }
    its(:termsOfService) { should == 'http://open-api.io/terms/' }
    its(:contact) { should be_a(RspecApiDocumentation::OpenApi::Contact) }
    its(:license) { should be_a(RspecApiDocumentation::OpenApi::License) }
    its(:version) { should == '1.0.0' }
  end
end
