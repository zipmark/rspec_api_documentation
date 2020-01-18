module RspecApiDocumentation
  module OpenApi
    class SecuritySchema < Node
      add_setting :type, :required => true
      add_setting :description
      add_setting :name
      add_setting :in
      add_setting :scheme
      add_setting :bearerFormat
      add_setting :flows
      add_setting :openIdConnectUrl
    end
  end
end
