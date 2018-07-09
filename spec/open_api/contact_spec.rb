require 'spec_helper'

describe RspecApiDocumentation::OpenApi::Contact do
  let(:node) { RspecApiDocumentation::OpenApi::Contact.new }
  subject { node }

  describe "default settings" do
    its(:name) { should == 'API Support' }
    its(:url) { should == 'http://www.open-api.io/support' }
    its(:email) { should == 'support@open-api.io' }
  end
end
