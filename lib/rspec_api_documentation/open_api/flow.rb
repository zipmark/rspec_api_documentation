module RspecApiDocumentation
  module OpenApi
    class Flow < Node
      add_setting :authorizationUrl, :required => true
      add_setting :tokenUrl, :required => true
      add_setting :refreshUrl
      add_setting :scopes, :required => true
    end
  end
end
