module RspecApiDocumentation
  module OpenApi
    class Contact < Node
      add_setting :name, :default => 'API Support'
      add_setting :url, :default => 'http://www.open-api.io/support'
      add_setting :email, :default => 'support@open-api.io'
    end
  end
end
