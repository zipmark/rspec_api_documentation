module RspecApiDocumentation
  module OpenApi
    class SecuritySchema < Node
      add_setting :type, :required => true
      add_setting :description
      add_setting :name
      add_setting :in
      add_setting :flow
      add_setting :authorizationUrl
      add_setting :tokenUrl
      add_setting :scopes
    end
  end
end
