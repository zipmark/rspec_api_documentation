require "spec_helper"
require "rspec_api_documentation/writers/combined_text_writer"

describe RspecApiDocumentation::Writers::CombinedTextExample do
  let(:metadata) { {} }
  let(:rspec_example) { double(:resource_name => "Foo Bar", :description => "ABCDEFG", :metadata => metadata) }
  let(:example) { RspecApiDocumentation::Writers::CombinedTextExample.new(rspec_example) }

  it "should format its resource name" do
    expect(example.resource_name).to eq("foo_bar")
  end

  it "should format its description" do
    expect(example.description).to eq("ABCDEFG\n-------\n\n")
  end

  context "given parameters" do
    let(:metadata) {{
      :parameters => [
        { :name => "foo", :description => "Foo!" },
        { :name => "bar", :description => "Bar!" }
      ]
    }}

    it "should format its parameters" do
      expect(example.parameters).to eq("Parameters:\n  * foo - Foo!\n  * bar - Bar!\n\n")
    end
  end

  it "renders nothing if there are no parameters" do
    expect(example.parameters).to eq("")
  end

  context "when there are requests" do
    let(:requests) {[
      {
        :request_method => "GET",
        :request_path => "/greetings",
        :request_headers => { "Header" => "value" },
        :request_query_parameters => { "foo" => "bar", "baz" => "quux" },
        :response_status => 200,
        :response_status_text => "OK",
        :response_headers => { "Header" => "value", "Foo" => "bar" },
        :response_body => "body"
      },
      {
        :request_method => "POST",
        :request_path => "/greetings",
        :request_body => "body",
        :response_status => 404,
        :response_status_text => "Not Found",
        :response_headers => { "Header" => "value" },
        :response_body => "body"
      },
      {
        :request_method => "DELETE",
        :request_path => "/greetings/1",
        :response_status => 200,
        :response_status_text => "OK",
        :response_headers => { "Header" => "value" },
      },
    ]}
    let(:metadata) {{ :requests => requests }}

    it "exposes the requests" do
      expect(example.requests).to eq([
        ["  GET /greetings\n  Header: value\n\n  baz=quux\n  foo=bar\n", "  Status: 200 OK\n  Foo: bar\n  Header: value\n\n  body\n"],
        ["  POST /greetings\n\n  body\n", "  Status: 404 Not Found\n  Header: value\n\n  body\n"],
        ["  DELETE /greetings/1\n", "  Status: 200 OK\n  Header: value\n"],
      ])
    end
  end

  it "returns the empty array if there are no requests" do
    expect(example.requests).to eq([])
  end
end
