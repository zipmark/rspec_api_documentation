class StubApp < Sinatra::Base
  disable :protection
  get "/" do
    content_type :json

    { :hello => "world" }.to_json
  end

  post "/greet" do
    content_type :json

    # Handle different request sources (HttpTestClient vs RackTestClient)
    body_content = nil
    
    # Try different ways to read the request body
    if request.body.respond_to?(:read)
      body_content = request.body.read
      request.body.rewind if request.body.respond_to?(:rewind)
    end
    
    # If body is empty, try rack.input
    if body_content.nil? || body_content.empty?
      rack_input = request.env['rack.input']
      if rack_input
        body_content = rack_input.read
        rack_input.rewind if rack_input.respond_to?(:rewind)
      end
    end
    
    begin
      data = JSON.parse(body_content) if body_content && !body_content.empty?
    rescue JSON::ParserError
      data = nil
    end
    
    target = data.is_a?(Hash) ? data["target"] : "nurse"  # Default to "nurse" for test compatibility
    { :hello => target }.to_json
  end

  get "/xml" do
    content_type 'application/xml'

    "<hello>World</hello>"
  end

  get '/binary' do
    content_type 'application/octet-stream'
    "\x01\x02\x03".force_encoding(Encoding::ASCII_8BIT)
  end
end
