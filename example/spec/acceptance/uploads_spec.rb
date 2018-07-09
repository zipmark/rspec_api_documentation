require 'acceptance_helper'

resource "Uploads" do
  authentication :basic, :api_key, :description => "Api Key description"

  let(:api_key) { "Basic #{Base64.encode64('user:password')}" }

  post "/uploads" do
    parameter :file, "New file to upload"

    let(:file) { Rack::Test::UploadedFile.new("spec/fixtures/file.png", "image/png") }

    example_request "Uploading a new file" do
      expect(status).to eq(201)
    end
  end
end
