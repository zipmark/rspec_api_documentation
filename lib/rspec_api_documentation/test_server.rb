module RspecApiDocumentation
  class TestServer < Struct.new(:session)
    delegate :example, :last_request, :last_response, :to => :session

    def call(env)
      return [200, {}, [""]]
    end
  end
end
