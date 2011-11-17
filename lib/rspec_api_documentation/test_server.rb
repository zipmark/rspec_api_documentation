module RspecApiDocumentation
  class TestServer < Struct.new(:session)
    delegate :example, :to => :session
  end
end
