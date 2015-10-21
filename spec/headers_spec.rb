require 'spec_helper'

class FakeHeaderable
  include RspecApiDocumentation::Headers

  def public_env_to_headers(env)
    env_to_headers(env)
  end
end

describe RspecApiDocumentation::Headers do
  let(:example) { FakeHeaderable.new }
  
  describe '#env_to_headers' do
    subject { example.public_env_to_headers(env) }

    context 'When the env contains "CONTENT_TYPE"' do
      let(:env) { { "CONTENT_TYPE" => 'multipart/form-data' } }

      it 'converts the header to "Content-Type"' do
        expect(subject['Content-Type']).to eq 'multipart/form-data'
      end
    end
  end

end
