require 'sinatra/base'
require 'json'

class StubApp < Sinatra::Base
  set :logging, false

  get "/" do
    content_type :json

    { :hello => "world" }.to_json
  end

  post "/greet" do
    content_type :json

    request.body.rewind
    begin
      data = JSON.parse request.body.read
    rescue JSON::ParserError
      request.body.rewind
      data = request.body.read
    end
    data.to_json
  end

  get "/xml" do
    content_type :xml

    "<hello>World</hello>"
  end
end

StubApp.run!
