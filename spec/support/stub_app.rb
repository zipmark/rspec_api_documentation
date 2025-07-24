class StubApp
  def call(env)
    req = Rack::Request.new(env)

    case "#{req.request_method} #{req.path_info}"
    when "GET /"
      [200, {'Content-Type' => 'application/json'}, [{ :hello => "world" }.to_json]]
    when "POST /greet"
      body = req.body.read
      req.body.rewind if req.body.respond_to?(:rewind)

      begin
        data = JSON.parse(body) if body && !body.empty?
      rescue JSON::ParserError
        data = nil
      end

      target = data.is_a?(Hash) ? data["target"] : "nurse"
      [200, {'Content-Type' => 'application/json', 'Content-Length' => '17'}, [{ :hello => target }.to_json]]
    when "GET /xml"
      [200, {'Content-Type' => 'application/xml'}, ["<hello>World</hello>"]]
    when "GET /binary"
      [200, {'Content-Type' => 'application/octet-stream'}, ["\x01\x02\x03".force_encoding(Encoding::ASCII_8BIT)]]
    else
      [404, {'Content-Type' => 'text/plain'}, ["Not Found"]]
    end
  end
end

